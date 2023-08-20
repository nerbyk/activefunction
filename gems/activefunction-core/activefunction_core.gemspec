# frozen_string_literal: true

require_relative "lib/active_function_core/version"

Gem::Specification.new do |spec|
  spec.name    = "active_function_core"
  spec.version = ActiveFunction::VERSION
  spec.authors = ["Nerbyk"]
  spec.email   = ["danil.maximov2000@gmail.com"]

  spec.summary = %(ActiveFunction core gem)
  spec.description = %(Provides core functionality, plugins and ruby-next integration for ActiveFunction)
  spec.homepage = "https://github.com/DanilMaximov/acitvefunction/gems/activefunction-core"
  spec.license = "MIT"
  spec.metadata = {
    "homepage_uri"    => "https://github.com/DanilMaximov/activefunction/gems/activefunction-core",
    "source_code_uri" => "https://github.com/DanilMaximov/activefunction/gems/activefunction-core",
    "changelog_uri"   => "https://github.com/DanilMaximov/activefunction/gems/activefunction-core/CHANGELOG.md"
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + Dir.glob("bin/**/*") + %w[sig/active_function_core.rbs sig/manifest.yml] + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency "ruby-next-core", ">= 0.15.3"
end
