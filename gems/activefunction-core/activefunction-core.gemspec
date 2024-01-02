# frozen_string_literal: true

require_relative "lib/active_function_core/version"

Gem::Specification.new do |spec|
  spec.name    = "activefunction-core"
  spec.version = ActiveFunctionCore::VERSION
  spec.authors = ["Nerbyk"]
  spec.email   = ["danil.maximov2000@gmail.com"]

  spec.summary     = %(ActiveFunction core gem)
  spec.description = %(Provides core functionality, plugins and ruby-next integration for ActiveFunction)
  spec.homepage    = "https://github.com/DanilMaximov/activefunction"
  spec.license     = "MIT"
  spec.metadata    = {
    "homepage_uri" => "https://github.com/DanilMaximov/activefunction-core",
    "source_code_uri" => "https://github.com/DanilMaximov/activefunction-core",
    "changelog_uri" => "https://github.com/DanilMaximov/activefunction-core/CHANGELOG.md"
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + %w[sig/active_function_core.rbs sig/manifest.yml] + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency "ruby-next-core", ">= 1.0.0"
end
