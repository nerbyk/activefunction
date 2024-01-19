# frozen_string_literal: true

require "test_helper"
require "active_function"

class Function < ActiveFunction::Base
  def index
    validate_request

    return if performed?

    @response.body                    = "Hello, world!"
    @response.status                  = 201
    @response.headers["Content-Type"] = "text/plain"
  end

  private def validate_request
    return if @request[:valid]

    @response.status = 400
    @response.commit!
  end
end

describe Function do
  subject { Function.process(:index, request) }

  let(:request) { {valid: true} }

  it "should proccess request & return response object as hash" do
    _(subject).must_equal({
      statusCode: 201,
      body:       "Hello, world!",
      headers:    {"Content-Type" => "text/plain"}
    })
  end

  describe "when request is invalid" do
    let(:request) { {valid: false} }

    it "should return response object as hash" do
      _(subject).must_equal({
        statusCode: 400,
        body:       nil,
        headers:    {}
      })
    end
  end
end
