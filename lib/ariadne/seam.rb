# frozen_string_literal: true

require "open3"
require "ariadne/parameter"

module Ariadne
  class Seam
    attr_reader :rank, :depth, :klass, :method_name, :prefix, :parameters, :return_value, :binding, :path

    class << self
      # We cannot make public methods because accessing the TracePoint
      # after it has been disabled would raise a RunTimeError
      # with message "access from outside".
      # We need to set the values while the TracePoint is enabled.
      def build(tracepoint, rank:, depth:)
        raise "tracepoint is disabled" unless tracepoint.enabled?

        new(rank: rank, depth: depth).tap do |seam|
          seam.instance_variable_set(:@klass, klass(tracepoint))
          seam.instance_variable_set(:@prefix, prefix(tracepoint))
          seam.instance_variable_set(:@method_name, method_name(tracepoint))
          seam.instance_variable_set(:@parameters, parameters(tracepoint))
          seam.instance_variable_set(:@path, path(tracepoint))
        end
      end

      private

      def klass(tracepoint)
        if tracepoint.self.is_a?(Module)
          tracepoint.self
        else
          tracepoint.self.class
        end
      end

      def method_name(tracepoint)
        tracepoint.method_id
      end

      def prefix(tracepoint)
        tracepoint.self.is_a?(Module) ? "." : "#"
      end

      def parameters(tracepoint)
        method = tracepoint.self.method(tracepoint.method_id)
        method.parameters.map do |parameter|
          Parameter.new(parameter, binding: tracepoint.binding)
        end
      rescue NoMethodError
        []
      end

      def path(tracepoint)
        tracepoint.path
      end
    end

    private

    def initialize(rank:, depth:)
      @rank = rank
      @depth = depth
    end
  end
end
