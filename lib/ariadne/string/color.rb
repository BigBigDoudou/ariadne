# frozen_string_literal: true

module Ariadne
  module String
    module Color
      COLORS = %w[
        black
        red
        green
        yellow
        blue
        magenta
        cyan
        gray
      ].freeze

      COLORS.each.with_index do |color, index|
        code = index + 30
        define_method(color) do
          "\e[#{code}m#{bleach}\e[0m"
        end
        bg_code = index + 40
        define_method("bg_#{color}") do
          "\e[#{bg_code}m#{bleach}\e[0m"
        end
      end

      def bleach
        gsub(/\e\[\d{1,2}m/, "")
      end
    end
  end
end

String.include Ariadne::String::Color
