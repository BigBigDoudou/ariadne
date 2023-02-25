# frozen_string_literal: true

require "open3"
require "ariadne/string/color"

module Ariadne
  class Log
    def initialize(seam)
      @seam = seam
    end

    def call
      puts text
      write_log
    end

    private

    def write_log
      File.open(Ariadne::Thread::LOG_FILE, "a") { _1.puts text.bleach }
    end

    def text
      @text ||=
        [
          rank,
          " ",
          depth_dashes,
          class_name,
          prefix,
          method_name,
          parameters,
          return_value_type
        ].join
    end

    def rank
      @seam.rank.to_s.rjust(4).gray
    end

    def depth_dashes
      ("-" * @seam.depth).gray.tap { _1 << " " if @seam.depth.positive? }
    end

    def class_name
      @seam.klass.name.green
    end

    def prefix
      @seam.prefix.gray
    end

    def method_name
      @seam.method_name.to_s.cyan
    end

    def return_value_type
      value = type(@seam.return_value)
      " -> #{value}".yellow
    end

    def parameters
      return if @seam.parameters.empty?

      [
        "(",
        @seam.parameters.flat_map { "#{_1.param}:  #{arg(_1)}" }.join(", "),
        ")"
      ].join.magenta
    end

    def arg(parameter)
      if parameter.type == :rest || %i[* ** &].include?(parameter.param)
        parameter.arg.map { type(_1) }.join(", ")
      else
        type(parameter.arg)
      end
    end

    def type(arg)
      case arg
      when "<?>" then "<?>"
      when TrueClass, FalseClass then "Boolean"
      when NilClass then "nil"
      else arg.class.to_s
      end
    end
  end
end
