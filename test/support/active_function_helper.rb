# frozen_string_literal: true

module ActiveFunctionHelper
  module FunctionCore
    def initialize(route = nil)
      @route     = route
      @performed = false
      @response  = {}
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

  def function_with_render
    Class.new do
      include FunctionCore
      include ActiveFunction::Functions::Rendering
    end
  end

  def function_with_core
    Class.new do
      include ActiveFunction::Functions::Core
      include ActiveFunction::Functions::Rendering
    end
  end
end

Minitest::Test.include ActiveFunctionHelper
