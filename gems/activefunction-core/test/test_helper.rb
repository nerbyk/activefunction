# frozen_string_literal: true

require "bundler/setup"
require "ruby-next/language/runtime" unless ENV["CI"]

require "minitest/autorun"
require "minitest/reporters"

require "active_function_core"

RubyNext::Language.setup_gem_load_path("test", transpile: true)

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
