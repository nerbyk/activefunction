# frozen_string_literal: true

require_relative "lib/active_function/version"

Gem::Specification.new do |spec|
  spec.name    = "activefunction"
  spec.version = ActiveFunction::VERSION
  spec.authors = ["Nerbyk"]
  spec.email   = ["danil.maximov2000@gmail.com"]

  spec.summary = %(
    Playground gem for Ruby 3.2+ features and more, designed for FaaS computing instances, but mostly used for experiments.
  )
  spec.description = %(
    ActiveFunction is a collection of gems designed to be used with Function as a Service (FaaS) computing instances. Inspired by aws-sdk v3 gem structure and rails/activesupport.

    Features:
    - Ruby Version Compatibility: Implemented with most of Ruby 3.2+ features, with support for Ruby versions >= 2.6 through the RubyNext transpiler (CI'ed).
    - Type Safety: Achieves type safety through the use of RBS and Steep (CI'ed) [Note: disabled due to the presence of Ruby::UnsupportedSyntax errors].
    - Plugins System: Provides a simple Plugin system inspired by Polishing Ruby Programming by Jeremy Evans to load gem plugins and self-defined plugins.
    - Gem Collection: Offers a collection of gems designed for use within ActiveFunction or as standalone components.
  )
  spec.homepage = "https://github.com/DanilMaximov/acitvefunction"
  spec.license = "MIT"
  spec.metadata = {
    "homepage_uri"    => "https://github.com/DanilMaximov/activefunction",
    "source_code_uri" => "https://github.com/DanilMaximov/activefunction",
    "changelog_uri"   => "https://github.com/DanilMaximov/activefunction/CHANGELOG.md"
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + 
    %w[sig/active_function.rbs sig/manifest.yml] + 
    %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "activefunction-core", "~> 0.2.2"
  
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "ruby-next", ">= 1.0.0"
  spec.add_development_dependency "minitest", "~> 5.15.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.4.3"
  spec.add_development_dependency "mocha", "~> 2.1.0"
end
