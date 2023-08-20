# frozen_string_literal: true

require_relative "lib/active_function_core/version"

Gem::Specification.new do |spec|
  spec.name    = "active_function_core"
  spec.version = ActiveFunction::VERSION
  spec.authors = ["Nerbyk"]
  spec.email   = ["danil.maximov2000@gmail.com"]

  spec.summary = %(ActiveFunction::Core)
  spec.description = %(Provides core functionality for ActiveFunction and ruby-next integration)
  spec.homepage = "https://github.com/DanilMaximov/acitvefunction/gems/active_function-core"
  spec.license = "MIT"
  spec.metadata = {
    "homepage_uri"    => "https://github.com/DanilMaximov/activefunction/gems/active_function-core",
    "source_code_uri" => "https://github.com/DanilMaximov/activefunction/gems/active_function-core",
    "changelog_uri"   => "https://github.com/DanilMaximov/activefunction/gems/active_function-core/CHANGELOG.md"
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + Dir.glob("bin/**/*") + %w[sig/active_function.rbs sig/manifest.yml] + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency "ruby-next-core", ">= 0.14.0"

  spec.add_development_dependency "ruby-next", ">= 0.14.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "minitest", "~> 5.15.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.4.3"
end
