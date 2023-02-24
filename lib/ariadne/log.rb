# frozen_string_literal: true

require "open3"
require "ariadne/helpers/text"
require "ariadne/helpers/value_format"

module Ariadne
  class Log
    include Helpers::Text
    include Helpers::ValueFormat

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
        Text(
          [
            rank,
            " ",
            depth_dashes,
            class_name,
            prefix,
            method_name,
            parameters,
            return_value
          ].join
        )
    end

    def rank
      Text(@seam.rank.to_s.rjust(4)).gray
    end

    def depth_dashes
      Text("-" * @seam.depth).gray.tap { _1 << " " if @seam.depth.positive? }
    end

    def class_name
      Text(@seam.klass.name).green
    end

    def prefix
      Text(@seam.prefix).gray
    end

    def method_name
      Text(@seam.method_name).cyan
    end

    def return_value
      value = Text(cast(@seam.return_value)).truncate(50)
      value = type(@seam.return_value) ? "<#{type(@seam.return_value)}> #{value}" : value
      Text(" -> #{value}").yellow
    end

    def parameters
      str =
        @seam.parameters.map do |parameter|
          arg = Text(cast(parameter.arg)).truncate(50)
          arg = type(parameter.arg) ? "<#{type(parameter.arg)}> #{arg}" : arg
          "#{parameter.param}: #{arg}"
        end.join(", ")
      Text(str.empty? ? "" : "(#{str})").magenta
    end
  end
end
