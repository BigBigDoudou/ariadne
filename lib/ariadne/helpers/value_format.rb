# frozen_string_literal: true

module Ariadne
  module Helpers
    module ValueFormat
      RUBY_LITERALS = [
        NilClass,
        String,
        Integer,
        Float,
        Proc,
        TrueClass,
        FalseClass,
        Symbol,
        Array,
        Range,
        Regexp,
        Hash
      ].freeze

      def type(value)
        return if value.is_a?(Class) || RUBY_LITERALS.include?(value.class)

        value.class.name
      end

      def cast(value)
        case value
        when NilClass
          "nil"
        when Proc
          "#<Proc>"
        when Class
          value.name
        when String
          "\"#{value}\""
        else
          value.to_s
        end
      end
    end
  end
end
