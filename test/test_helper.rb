# frozen_string_literal: true

require "bundler/setup"
require "ruby-next/language/runtime"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
