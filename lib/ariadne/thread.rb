# frozen_string_literal: true

require "open3"
require "ariadne/seam"
require "ariadne/log"

module Ariadne
  class Thread
    attr_reader :seams

    LOG_FILE = "thread.log"
    DEFAULT_INCLUDE_PATHS = Open3.capture3("pwd").first.strip
    DEFAULT_EXCLUDE_PATHS = [].freeze

    def initialize(include_paths: nil, exclude_paths: nil)
      @include_paths = Array(include_paths) || DEFAULT_INCLUDE_PATHS
      @exclude_paths = Array(exclude_paths) || DEFAULT_EXCLUDE_PATHS
      @seams = []
    end

    def call
      prepare
      open_file
      trace.enable
      yield
    ensure
      trace.disable
      log
      close_file
    end

    private

    def prepare
      @rank = 0
      @depth = 0
      @seams = []
    end

    def open_file
      @file = File.open(LOG_FILE, "w")
    end

    def close_file
      @file.close
    end

    def trace
      @trace ||=
        TracePoint.new(:call, :return) do |tracepoint|
          next if tracepoint.self.is_a?(TracePoint)

          case tracepoint.event
          when :call
            on_call(tracepoint)
          when :return
            on_return(tracepoint)
          end
        end
    end

    def on_call(tracepoint)
      return unless selected?(tracepoint)

      seam = Seam.build(tracepoint, rank: @rank, depth: @depth)
      @seams << seam

      @rank += 1
      @depth += 1
    end

    def on_return(tracepoint)
      return unless selected?(tracepoint)

      @depth -= 1

      seam = @seams.reverse.find { _1.depth == @depth }
      seam&.instance_variable_set(:@return_value, tracepoint.return_value)
      seam&.instance_variable_set(:@binding, tracepoint.binding)
    end

    def selected?(tracepoint)
      @include_paths.any? { tracepoint.path.include?(_1) } &&
        @exclude_paths.none? { tracepoint.path.include?(_1) }
    end

    def log
      @seams.each { Log.new(_1).call }
    end
  end
end
