# frozen_string_literal: true

class User
  attr_reader :name, :role, :access_key

  def self.build(name)
    new(name).tap do |user|
      user.access_key = generate_access_key
    end
  end

  def self.import(users)
    users.each(&:validate)
    true
  end

  def self.generate_access_key
    rand(0..100)
  end

  def initialize(name)
    @name = name
  end

  def access_key=(value)
    @access_key = value
  end

  def role=(value)
    @role = value
  end

  def admin=(value)
    @admin = value
  end

  def email=(value)
    @email = value
  end

  def validate
    access_key?
  end

  def access_key?
    !access_key.nil?
  end
end
