# frozen_string_literal: true

require "bundler/setup"
require "ruby-next/language/runtime"

require "minitest/autorun"
require "minitest/reporters"

require "active_function"

ActiveFunction.plugin :callbacks
ActiveFunction.plugin :strong_parameters
ActiveFunction.plugin :rendering

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
