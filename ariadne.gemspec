# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require_relative "lib/ariadne/version"

Gem::Specification.new do |spec|
  spec.name                  = "ariadne"
  spec.version               = Ariadne::VERSION
  spec.authors               = ["Edouard Piron"]
  spec.email                 = ["ed.piron@gmail.com"]
  spec.homepage              = "https://github.com/BigBigDoudou/ariadne"
  spec.summary               = "Follow the code"
  spec.description           = "Follow the code"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = "https://github.com/perangusta/ariadne"
  spec.metadata["changelog_uri"]         = "https://github.com/perangusta/ariadne/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "colorize"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"

  spec.files = Dir.glob("lib/**/*")
end
