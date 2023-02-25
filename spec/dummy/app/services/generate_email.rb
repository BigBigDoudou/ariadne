# frozen_string_literal: true

module Services
  class GenerateEmail
    def initialize(user)
      @user = user
    end

    def call
      "#{@user.name.downcase.gsub(" ", ".")}@ariadne.#{domain}"
    end

    def domain
      case @user.role
      when :engineer then "dev"
      else "com"
      end
    end
  end
end
