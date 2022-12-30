# frozen_string_literal: true

require "test_helper"

describe ActiveFunction::Functions::Rendering do
  describe "#render" do
    let(:function_class) { function_with_render }
    let(:route) { :index }
    let(:function) { function_class.new(route) }
    let(:response) { function.instance_variable_get(:@response) }

    it "should render json" do
      function.render(json: {a: 1, b: 2})

      assert response[:statusCode], 200
      assert response[:headers], {"Content-Type" => "application/json"}
      assert response[:body], '{"a":1,"b":2}'
    end

    it "should render json with status" do
      function.render(status: 201, json: {a: 1, b: 2})

      assert response[:statusCode], 201
      assert response[:headers], {"Content-Type" => "application/json"}
      assert response[:body], '{"a":1,"b":2}'
    end

    it "should render json with head" do
      function.render(head: {"X-Test" => "test"}, json: {a: 1, b: 2})

      assert response[:statusCode], 200
      assert response[:headers], {"Content-Type" => "application/json", "X-Test" => "test"}
      assert response[:body], '{"a":1,"b":2}'
    end

    it "should raise DoubleRenderError" do
      function.render(json: {a: 1, b: 2})

      assert_raises ActiveFunction::DoubleRenderError do
        function.render(json: {a: 1, b: 2})
      end
    end
  end
end
