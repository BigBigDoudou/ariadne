# frozen_string_literal: true

require "open3"

module Ariadne
  class Parameter < SimpleDelegator
    def initialize(parameter, binding:)
      super(parameter)
      @binding = binding
    end

    def param
      last
    end

    def arg
      @binding.local_variable_get(last)
    rescue NameError
      "?"
    end
  end
end
