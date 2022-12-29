# frozen_string_literal: true

require "test_helper"

describe ActiveFunction::Functions::Callbacks do
  describe "#process" do
    let(:function_class) { function_with_callbacks }
    let(:route) { :index }
    let(:function) { function_class.new(route) }

    it "should call callbacks" do
      function_class.class_eval do
        before_action :first
        after_action :second
        def first = @first = "Biba"

        def second = @second = "Boba"
      end

      function.send(:process)

      assert function.instance_variable_get(:@performed), true
      assert function.instance_variable_get(:@first), "Biba"
      assert function.instance_variable_get(:@second), "Boba"
    end
    it "should call several callbacks of the same type" do
      function_class.class_eval do
        before_action :first
        before_action :second
        def first = @first = "Biba"

        def second = @second = "Boba"
      end

      function.send(:process)

      assert function.instance_variable_get(:@performed), true
      assert function.instance_variable_get(:@first), "Biba"
      assert function.instance_variable_get(:@second), "Boba"
    end

    it "should call conditional callbacks" do
      function_class.class_eval do
        before_action :first, if: :condition
        after_action :second, if: :condition2
        def first  = @first = "Biba"

        def second = @second = "Boba"

        def condition  = true

        def condition2 = false
      end

      function.send(:process)

      assert function.instance_variable_get(:@performed), true
      assert function.instance_variable_get(:@first), "Biba"
      assert_nil function.instance_variable_get(:@second)
    end

    it "should call callbacks with only option" do
      function_class.class_eval do
        before_action :first, only: %i[index]
        after_action :second, only: %i[show]
        def first  = @first = "Biba"

        def second = @second = "Boba"
      end

      function.send(:process)

      assert function.instance_variable_get(:@performed), true
      assert function.instance_variable_get(:@first), "Biba"
      assert_nil function.instance_variable_get(:@second)
    end
  end
end
