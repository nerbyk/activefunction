# frozen_string_literal: true

require_relative "lib/active_function/version"

Gem::Specification.new do |spec|
  spec.name = "activefunction"
  spec.version = ActiveFunction::VERSION
  spec.authors = ["Nerbyk"]
  spec.email = ["danil.maximov2000@gmail.com"]

  spec.summary = "activedispath like gem for aws lambda"
  spec.description = "activedispath like gem for aws lambda functions development which provides routing, params, callbacks, rendering and other features"
  spec.homepage = "https://github.com/DanilMaximov/mobility-widget/acitvefunction"

  spec.metadata = {
    "homepage_uri" => "https://github.com/DanilMaximov/mobility-widget/acitvefunction",
    "source_code_uri" => "https://github.com/DanilMaximov/mobility-widget",
    "changelog_uri" => "https://github.com/DanilMaximov/mobility-widget/CHANGELOG.md"
  }

  spec.license = "MIT"

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") +
    Dir.glob("bin/**/*") + %w[sig/anyway_config.rbs sig/manifest.yml] +
    %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency "ruby-next-core", ">= 0.14.0"

  spec.add_development_dependency "ruby-next", ">= 0.14.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "minitest", "~> 5.15.0"
end
