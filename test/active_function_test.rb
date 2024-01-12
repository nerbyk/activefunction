# frozen_string_literal: true

require "test_helper"

DefaultActiveFunction          = Class.new(ActiveFunction)
CallbacksActiveFunction        = Class.new(ActiveFunction) { plugin :callbacks }
StrongParametersActiveFunction = Class.new(ActiveFunction) { plugin :strong_parameters }
RenderingActiveFunction        = Class.new(ActiveFunction) { plugin :rendering }
GeneralActiveFunction          = Class.new(ActiveFunction) {
  plugin :callbacks
  plugin :strong_parameters
  plugin :rendering
}

class TestFunction < DefaultActiveFunction::Base
  def index
    @response.body = @request
  end
end

class TestFunctionWithCallbacks < CallbacksActiveFunction::Base
  before_action :set_first

  def index
    @response.body = {first: @first}
  end

  private

  def set_first
    @first = 1
  end
end

class TestFunctionWithParameters < StrongParametersActiveFunction::Base
  def index
    @response.body = params
      .require(:data)
      .permit(:id, message: %i[text])
      .to_h
  end
end

class TestFunctionWithRendering < RenderingActiveFunction::Base
  def index
    render json: {a: 1, b: 2}, status: 201, head: {"X-Test" => "test"}
  end
end

class TestFunctionWithCallbacksAndParameters < GeneralActiveFunction::Base
  before_action :load_user

  def index
    render json: @user
  end

  private

  def load_user
    @user = params
      .require(:data)
      .permit(:id, message: %i[text])
      .to_h
  end
end

class ActiveFunctionTest < Minitest::Test
  def test_default_function_processing
    response = TestFunction.process(:index, {a: 1, b: 2})

    assert_equal response, {
      statusCode: 200,
      body:       {a: 1, b: 2},
      headers:    {}
    }
  end

  def test_function_processing_with_callbacks
    response = TestFunctionWithCallbacks.process(:index, {})

    assert_equal(response, {
      statusCode: 200,
      body:       {first: 1},
      headers:    {}
    })
  end

  def test_function_processing_with_inheritted_callbacks
    response = Class.new(TestFunctionWithCallbacks).process(:index, {})

    assert_equal(response, {
      statusCode: 200,
      body:       {first: 1},
      headers:    {}
    })
  end

  def test_function_processing_with_params
    data = {data: {id: 1, name: "Pupa", message: {id: 1, text: "test"}}}

    response = TestFunctionWithParameters.process(:index, data)

    assert_equal(response, {
      statusCode: 200,
      body:       {id: 1, message: {text: "test"}},
      headers:    {}
    })
  end

  def test_function_processing_with_rendering
    response = TestFunctionWithRendering.process(:index, {})

    assert_equal(response, {
      statusCode: 201,
      body:       {a: 1, b: 2}.to_json,
      headers:    {"X-Test" => "test", "Content-Type" => "application/json"}
    })
  end

  def test_function_processing_with_all_plugins
    data = {data: {id: 1, name: "Pupa", message: {id: 1, text: "test"}}}

    response = TestFunctionWithCallbacksAndParameters.process(:index, data)

    assert_equal(response, {
      statusCode: 200,
      body:       {id: 1, message: {text: "test"}}.to_json,
      headers:    {"Content-Type" => "application/json"}
    })
  end
end
