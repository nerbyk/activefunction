# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

describe ActiveFunctionCore::Plugins::Hooks do
  let(:klass) do
    Class.new do
      include ActiveFunctionCore::Plugins::Hooks

      def payout
        # do nothing
      end
    end
  end

  let(:hooked_method) { :payout }

  subject { klass }

  describe "included" do
    it { _(subject).must_respond_to :define_hooks_for }
    it { _(subject).must_respond_to :hooks }
    it { _(subject).must_respond_to :set_callback }
    it { _(subject).must_respond_to :set_callback_options }
    it { _(subject).must_respond_to :callback_options }
  end

  describe "inherited" do
    subject { Class.new(klass) }

    before do
      klass.define_hooks_for hooked_method
      klass.set_callback :before, hooked_method, :set_pupa_salary
      klass.set_callback :after, hooked_method, :set_lupa_salary, if: :executable?
    end

    it "should inherit hooks attributes" do
      _(subject.hooks).must_equal klass.hooks
      _(subject.callback_options).must_equal klass.callback_options
    end

    it "should inherit copy of attributes" do
      _(subject.hooks.object_id).wont_equal klass.hooks.object_id
      _(subject.hooks[hooked_method].object_id).wont_equal klass.hooks[hooked_method].object_id
      _(subject.hooks[hooked_method].callbacks.object_id).wont_equal klass.hooks[hooked_method].callbacks.object_id

      _(subject.callback_options.object_id).wont_equal klass.callback_options.object_id
    end
  end

  describe "::define_hooks_for" do
    before do
      subject.define_hooks_for hooked_method
    end

    it { _(subject).must_respond_to :"before_#{hooked_method}" }
    it { _(subject).must_respond_to :"after_#{hooked_method}" }

    it "should create hook" do
      _(subject.hooks.keys).must_equal [hooked_method]
      _(subject.hooks[hooked_method]).must_be_kind_of ActiveFunctionCore::Plugins::Hooks::Hook
    end

    it "should raise ArgumentError for undefined method" do
      assert_raises ArgumentError do
        subject.define_hooks_for :missing_method
      end
    end

    it "should raise ArgumentError for already hooked method" do
      assert_raises ArgumentError do
        subject.define_hooks_for hooked_method
      end
    end

    describe "::before_[hooked_method]" do
      before do
        subject.send :"before_#{hooked_method}", :set_pupa_salary
      end

      it "should add before callback" do
        _(subject.hooks[hooked_method].callbacks[:before].size).must_equal 1
      end
    end

    describe "::after_[hooked_method]" do
      before do
        subject.send :"after_#{hooked_method}", :set_lupa_salary
      end

      it "should add after callback" do
        _(subject.hooks[hooked_method].callbacks[:after].size).must_equal 1
      end
    end
  end

  describe "::set_callback" do
    before do
      subject.define_hooks_for hooked_method
    end

    it "should add before callback" do
      subject.set_callback :before, hooked_method, :set_pupa_salary

      _(subject.hooks[hooked_method].callbacks[:before].size).must_equal 1
      _(subject.hooks[hooked_method].callbacks[:before][0]).must_be_kind_of ActiveFunctionCore::Plugins::Hooks::Hook::Callback
    end

    it "should add after callback" do
      subject.set_callback :after, hooked_method, :set_lupa_salary

      _(subject.hooks[hooked_method].callbacks[:after].size).must_equal 1
      _(subject.hooks[hooked_method].callbacks[:after][0]).must_be_kind_of ActiveFunctionCore::Plugins::Hooks::Hook::Callback
    end

    it "should add callback with options" do
      subject.set_callback :before, hooked_method, :set_pupa_salary, if: :executable?, unless: :not_executable?

      _(subject.hooks[hooked_method].callbacks[:before].first.options.size).must_equal 2
    end

    it "should raise ArgumentError for undefined hook" do
      assert_raises ArgumentError do
        subject.set_callback :before, :missing_method, :set_pupa_salary
      end
    end

    it "should raise ArgumentError for undefined options" do
      assert_raises ArgumentError do
        subject.set_callback :before, hooked_method, :set_pupa_salary, missing_option: true
      end
    end
  end

  describe "::set_callback_options" do
    before do
      subject.define_hooks_for hooked_method
      subject.set_callback_options custom_option: ->(v, context:) {}
    end

    it { _(subject.callback_options.keys).must_equal %i[if unless custom_option] }

    it "should create custom callback options" do
      subject.set_callback :before, hooked_method, :set_pupa_salary, custom_option: :executable?, if: :executable?, unless: :not_executable?

      _(subject.hooks[hooked_method].callbacks[:before].first.options.size).must_equal 3
    end
  end
end
