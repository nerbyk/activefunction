# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

describe ActiveFunctionCore::Plugins::Hooks::Hook do
  subject { described_class.new(:hook) }

  let(:described_class) { ActiveFunctionCore::Plugins::Hooks::Hook }
  let(:klass) do
    Class.new do
      include ActiveFunctionCore::Plugins::Hooks
      def hook
      end

      def before_hook
      end

      def after_hook
      end
    end
  end

  describe "#add_callback" do
    it "should add callback" do
      subject.add_callback(type: :before, target: :set_pupa_salary)

      _(subject.callbacks[:before]).must_equal [described_class::Callback[{}, :set_pupa_salary]]
    end

    it "should raise ArgumentError when callback already defined" do
      subject.add_callback(type: :before, target: :set_pupa_salary)

      assert_raises(ArgumentError) do
        subject.add_callback(type: :before, target: :set_pupa_salary)
      end
    end
  end

  describe "#run_callbacks" do
    let(:context) { klass.new }

    before do
      subject.add_callback(type: :before, target: :before_hook)
      subject.add_callback(type: :after, target: :after_hook)
    end

    it "should run callbacks" do
      context.expects(:before_hook).once
      context.expects(:after_hook).once

      subject.run_callbacks(context) { context.hook }
    end
  end
end
