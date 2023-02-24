# frozen_string_literal: true

module Ariadne
  module Helpers
    module Text
      class Text < String
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

        def initialize(str)
          super(str.to_s)
        end

        def truncate(size)
          if self.size > size
            Text.new("#{self[..size]}...")
          else
            self
          end
        end

        def bleach
          gsub(/\e\[\d{1,2}m/, "")
        end
      end

      def Text(str) # rubocop:disable Naming/MethodName
        Text.new(str)
      end
    end
  end
end
