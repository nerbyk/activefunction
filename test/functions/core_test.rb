# frozen_string_literal: true

require "test_helper"
require "json"

describe ActiveFunction::Functions::Core do
  let(:function_class) { Class.new(function_with_core) { def route; :index; end } } # rubocop:disable Style/SingleLineMethods
  let(:function) { function_class.new(event: event.to_json, context: nil) }
  let(:event) { {a: 1, b: 2} }

  describe "#process" do
    it "processes the function and returns default response hash" do
      function_class.class_eval do
        def index
          @index = "index"
          render
        end
      end

      response = function.send(:process)

      assert function.instance_variable_get(:@index), "index"
      assert response, {statusCode: 200, headers: {}, body: {}}
    end

    it "raises an error if the route is not defined" do
      assert_raises ActiveFunction::MissingRouteMethod do
        function.send(:process)
      end
    end

    it "raises an error if action wasn't performed" do
      function_class.class_eval do
        def index
          nil
        end
      end

      assert_raises ActiveFunction::NotRenderedError do
        function.send(:process)
      end
    end
  end
end
