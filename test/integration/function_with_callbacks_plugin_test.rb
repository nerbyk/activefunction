# frozen_string_literal: true

require "test_helper"

ActiveFunction.config do
  plugin :callbacks
end

class BaseFunction < ActiveFunction::Base
  def index
    # do nothing
  end

  private

  def set_before
    @response.body = {before: 1}
  end

  def set_after
    if @response.body.nil?
      @response.body = {after: 2}
    else
      @response.body.merge!({after: 2})
    end
  end
end

class FunctionWithCallbacks < BaseFunction
  before_action :set_before
  after_action :set_after
end

describe FunctionWithCallbacks do
  let(:expected_response) do
    {
      statusCode: 200,
      body:       {before: 1, after: 2},
      headers:    {}
    }
  end

  it "should process request & return response object as hash" do
    _(FunctionWithCallbacks.process(:index, {})).must_equal(expected_response)
  end

  it "should inherit callbacks" do
    klass = Class.new(FunctionWithCallbacks)

    _(klass.process(:index, {})).must_equal(expected_response)
  end

  it "should inherit callbacks alternative way" do
    class InheritedFunctionWithCallbacks < FunctionWithCallbacks
    end

    _(InheritedFunctionWithCallbacks.process(:index, {})).must_equal(expected_response)
  end
end

class FunctionWithOptionedCallbacks < BaseFunction # provides :set_before, :set_after, :index instance methods
  before_action :set_before, only: %i[index], if: :request_valid?
  after_action :set_after, unless: :request_valid?

  def show
    # do nothing
  end

  private

  def request_valid?
    @request[:valid] == true
  end
end

describe FunctionWithOptionedCallbacks do
  subject { FunctionWithOptionedCallbacks.process(action, request) }

  let(:action) { :index }
  let(:request) { {valid: true} }
  let(:expected_response) do
    {
      statusCode: 200,
      body:       {before: 1},
      headers:    {}
    }
  end

  it "should process before callbacks" do
    _(subject).must_equal(expected_response)
  end

  describe "when before callbacks skipped" do
    let(:request) { {valid: false} }

    before do
      expected_response[:body] = {after: 2}
    end

    describe "when :only option invalid" do
      let(:action) { :show }

      it "should NOT process before callback" do
        _(subject).must_equal(expected_response)
      end
    end

    describe "when :if option invalid" do
      it "should NOT process before callback" do
        _(subject).must_equal(expected_response)
      end
    end
  end
end
