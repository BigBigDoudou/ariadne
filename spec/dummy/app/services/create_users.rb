# frozen_string_literal: true

module Services
  class CreateUsers
    def initialize(names:)
      @names = names
    end

    def call
      users = @names.map { User.build(_1) }
      users.each { yield(_1) }
      users.each { _1.email = generate_email(_1) }
      User.import(users)
    end

    def generate_email(user)
      Services::GenerateEmail.new(user).call
    end
  end
end
