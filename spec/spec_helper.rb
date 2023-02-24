# frozen_string_literal: true

require "pry"

require "ariadne"

Dir["spec/dummy/app/**/*.rb"].each { require_relative "../#{_1}" }
