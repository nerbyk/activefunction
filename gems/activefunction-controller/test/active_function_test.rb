# frozen_string_literal: true

require "test_helper"

class TestFunction < ActiveFunction::Controller::Base
  def index
    render json: {a: 1, b: 2}, status: 201, head: {"X-Test" => "test"}
  end
end

class TestFunctionWithCallbacks < ActiveFunction::Controller::Base
  before_action :set_first

  def index
    render json: {first: @first}
  end

  private

  def set_first
    @first = 1
  end
end

class TestFunctionWithParameters < ActiveFunction::Controller::Base
  def index
    render json: params.require(:data).permit(:id, message: %i[text]).to_h
  end
end

class ActiveFunctionTest < Minitest::Test
  def test_function_processing
    response = TestFunction.process(:index, {})

    assert_equal(response, {
      statusCode: 201,
      body:       {a: 1, b: 2}.to_json,
      headers:    {"Content-Type" => "application/json", "X-Test" => "test"}
    })
  end

  def test_function_processing_with_callbacks
    response = TestFunctionWithCallbacks.process(:index, {})

    assert_equal(response, {
      statusCode: 200,
      body:       {first: 1}.to_json,
      headers:    {"Content-Type" => "application/json"}
    })
  end

  def test_function_processing_with_inheritted_callbacks
    response = Class.new(TestFunctionWithCallbacks).process(:index, {})

    assert_equal(response, {
      statusCode: 200,
      body:       {first: 1}.to_json,
      headers:    {"Content-Type" => "application/json"}
    })
  end

  def test_function_processing_with_params
    data = {data: {id: 1, name: "Pupa", message: {id: 1, text: "test"}}}

    response = TestFunctionWithParameters.process(:index, data)

    assert_equal(response, {
      statusCode: 200,
      body:       {id: 1, message: {text: "test"}}.to_json,
      headers:    {"Content-Type" => "application/json"}
    })
  end
end
