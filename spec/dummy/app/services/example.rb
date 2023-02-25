# frozen_string_literal: true

module Services
  class Example
    def self.class_method(klass)
      klass
      yield
    end

    def call
      method_with_args_and_kwargs(1, 2, x: "foo", y: "bar") { 42 }
    end

    def method_with_args_and_kwargs(a, b, x:, y:)
      method_with_anonymous_args_and_kwargs(1, 2, x: "foo", y: "bar") { yield }
    end

    def method_with_anonymous_args_and_kwargs(*args, **kwargs, &block)
      method_forwarding_all_args(Integer, &block)
    end

    def method_forwarding_all_args(...)
      self.class.class_method(...)
    end
  end
end
