# frozen_string_literal: true

module ActiveFunctionHelper
  module FunctionCore
    def initialize(route = nil)
      @route     = route
      @performed = false
    end

    private def process
      @performed = true
    end
  end

  def function_with_callbacks
    Class.new do
      include FunctionCore
      include ActiveFunction::Functions::Callbacks
    end
  end
end

Minitest::Test.include ActiveFunctionHelper
