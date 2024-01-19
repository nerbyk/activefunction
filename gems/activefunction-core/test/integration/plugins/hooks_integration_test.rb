# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"
require "active_function_core"

class TestClass
  include ActiveFunctionCore::Plugins::Hooks

  set_callback_options only: ->(only_methods, context:) { only_methods.include?(context.action) }

  define_hooks_for :your_method

  before_your_method :do_something_before, only: %w[foo]

  def action
    "foo"
  end

  def your_method
    nil
  end

  private

  def do_something_before
    nil
  end
end

describe TestClass do
  subject { TestClass.new }

  it "should execute callback" do
    subject.expects(:do_something_before).once

    subject.your_method
  end

  describe "when custom option fails" do
    before do
      TestClass.any_instance.stubs(:action).returns("baz")
    end

    it "should not execute callback" do
      TestClass.any_instance.expects(:do_something_before).never

      subject.your_method
    end
  end
end
