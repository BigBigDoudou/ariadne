# frozen_string_literal: true

require "colorize"

module Ariadne
  class Log
    TEXTS = {
      rank: :white,
      depth_dashes: :white,
      class_name: :green,
      prefix: :blue,
      method_name: :blue,
      parameters: :magenta,
      return_value_type: :yellow
    }.freeze

    def initialize(seam)
      @seam = seam
    end

    def call
      puts log
      write_log
    end

    private

    def log
      @log ||=
        TEXTS.map do |method, color|
          __send__(method).colorize(color)
        end.join
    end

    def write_log
      File.open(Ariadne::Thread::LOG_FILE, "a") { _1.puts log.uncolorize }
    end

    def rank
      @seam.rank.to_s.rjust(4)
    end

    def depth_dashes
      str = +" "
      if @seam.depth.positive?
        str << ("-" * @seam.depth)
        str << " "
      end
      str
    end

    def class_name
      @seam.klass.name
    end

    def prefix
      @seam.prefix
    end

    def method_name
      @seam.method_name.to_s
    end

    def return_value_type
      value = type(@seam.return_value)
      " -> #{value}"
    end

    def parameters
      return "" if @seam.parameters.empty?

      [
        "(",
        @seam.parameters.flat_map { "#{_1.param}:  #{arg(_1)}" }.join(", "),
        ")"
      ].join
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
