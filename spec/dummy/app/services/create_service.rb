# frozen_string_literal: true

module Services
  class CreateService < ApplicationService
    include ServiceHelper

    def initialize(arg, kwarg:)
      @arg = arg
      @kwarg = kwarg
    end

    def call
      method_a(42, CreateService)
      method_b(kwarg: 42)
      method_c("foo", "bar")
      method_d(42, kwarg: 43) { 44 }
      yield
      method_a(1, 2)
      validate
      ServiceHelper.validate
      1000
    end

    def method_a(x, y)
      return unless [x, y].all? { _1.is_a? Integer }

      x + y
    end

    def method_b(kwarg:)
      kwarg % 2
    end

    def method_c(*args)
      args.join("-")
    end

    def method_d(*args, **kwargs, &block)
      method_e(*args, **kwargs, &block)
    end

    def method_e(arg, kwarg:)
      yield *
        arg * kwarg
    end
  end
end
