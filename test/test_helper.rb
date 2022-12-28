# frozen_string_literal: true
require "bundler/setup"

require "minitest/autorun"
require "minitest/reporters"

require "active_function"

require "./test/support/active_function_helper"

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]