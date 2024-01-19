# frozen_string_literal: true

require "test_helper"

fork do
  require "active_function"

  ActiveFunction.config do
    plugin :rendering
  end

  class FunctionWithRendering < ActiveFunction::Base
    def full_response
      render json: @request[:data], status: 201, head: {"X-Test" => "test"}
    end

    def status_response
      render status: 301
    end

    def head_response
      render head: {"X-Test" => "test"}
    end

    def json_response
      render json: @request[:data]
    end
  end

  describe FunctionWithRendering do
    subject { FunctionWithRendering.process(action, request) }

    let(:action) { :full_response }
    let(:request) { {data: {a: 1, b: 2}} }

    it "should return response object" do
      _(subject).must_equal({
        statusCode: 201,
        body:       {a: 1, b: 2}.to_json,
        headers:    {"X-Test" => "test", "Content-Type" => "application/json"}
      })
    end

    describe "when only status rendered" do
      let(:action) { :status_response }

      it "should return response object" do
        _(subject).must_equal({
          statusCode: 301,
          body:       "{}",
          headers:    {"Content-Type" => "application/json"}
        })
      end
    end

    describe "when only head rendered" do
      let(:action) { :head_response }

      it "should return response object" do
        _(subject).must_equal({
          statusCode: 200,
          body:       "{}",
          headers:    {"X-Test" => "test", "Content-Type" => "application/json"}
        })
      end
    end

    describe "when only json rendered" do
      let(:action) { :json_response }

      it "should return response object" do
        _(subject).must_equal({
          statusCode: 200,
          body:       {a: 1, b: 2}.to_json,
          headers:    {"Content-Type" => "application/json"}
        })
      end
    end
  end
end
