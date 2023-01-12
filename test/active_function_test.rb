# frozen_string_literal: true

require "test_helper"

class TestFunction < ActiveFunction::Base
  def index
    render json: {a: 1, b: 2}, status: 201, head: {"X-Test" => "test"}
  end
end

class ActiveFunctionTest < Minitest::Test
  def test_function_processing
    response = TestFunction.process(:index, request: {})

    assert_equal(response, {
      statusCode: 201,
      body:       {a: 1, b: 2}.to_json,
      headers:    {"Content-Type" => "application/json", "X-Test" => "test"}
    })
  end
end
