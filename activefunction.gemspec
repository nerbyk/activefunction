# frozen_string_literal: true

require_relative "lib/active_function/version"

Gem::Specification.new do |spec|
  spec.name    = "activefunction"
  spec.version = ActiveFunction::VERSION
  spec.authors = ["Nerbyk"]
  spec.email   = ["danil.maximov2000@gmail.com"]

  spec.summary = %(
    rails/action_controller like gem which provides
    callbacks, strong parameters & rendering features.
  )
  spec.description = %(
    rails/action_controller like gem which provides lightweight callbacks,
    strong parameters & rendering features. It's designed to be used with
    AWS Lambda functions, but can be also used with any Ruby application.

    Implemented with some of ruby 3.x features, but also supports
    ruby 2.6.x thanks to RubyNext transpiler. Type safety achieved
    by RBS and Steep.
  )
  spec.homepage = "https://github.com/DanilMaximov/acitvefunction"
  spec.license = "MIT"
  spec.metadata = {
    "homepage_uri"    => "https://github.com/DanilMaximov/activefunction",
    "source_code_uri" => "https://github.com/DanilMaximov/activefunction",
    "changelog_uri"   => "https://github.com/DanilMaximov/activefunction/CHANGELOG.md"
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + Dir.glob("bin/**/*") + %w[sig/active_function.rbs sig/manifest.yml] + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "activefunction-core", ">= 0.1.1"

  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "minitest", "~> 5.15.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.4.3"
end
