# frozen_string_literal: true

class User
  def self.build(name)
    new(name: name)
  end

  def initialize(name)
    @name = name
  end
end
