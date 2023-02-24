# frozen_string_literal: true

require_relative "service_helper"

module Services
  class ApplicationService
    include ServiceHelper

    def self.call(*args, **kwargs, &block)
      new(*args, **kwargs).send(:call, &block)
    end
  end
end
