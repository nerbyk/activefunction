# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

require "active_function"
require "active_function/functions/callbacks"

class CallbackTestFunction < Class.new {
  def process
  end
}
  include ActiveFunction::Functions::Callbacks

  def index
    nil
  end

  private # callback methods

  def first
    nil
  end
end

describe ActiveFunction::Functions::Callbacks do
  let(:klass) { Class.new(CallbackTestFunction) }

  subject { klass.new }

  it "should execute callback around process" do
    klass.set_callback :before, :action, :first

    subject.expects(:first).once

    subject.process
  end

  it "should execute before callback" do
    klass.before_action :first

    subject.expects(:first).once

    subject.process
  end

  it "should execute after callback" do
    klass.after_action :first

    subject.expects(:first).once

    subject.process
  end

  describe "when :only option is specified" do
    before do
      klass.set_callback :before, :action, :first, only: %i[index]
    end

    it "should execute callback" do
      klass.define_method(:action_name) { :index }

      subject.expects(:first).once

      subject.process
    end

    it "should NOT execute callback" do
      klass.define_method(:action_name) { :show }

      subject.expects(:first).never

      subject.process
    end
  end
end
