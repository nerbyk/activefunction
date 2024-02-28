# frozen_string_literal: true

require "test_helper"

require "active_function"

ActiveFunction.config do
  plugin :strong_parameters
  plugin :rendering
  plugin :callbacks
end

class Function < ActiveFunction::Base
  before_action :parse_request, only: [:index], if: :request_valid?

  def index
    render status: 500 unless @parsed_request

    render json: @parsed_request, status: 301 unless performed?
  end

  private

  def parse_request
    @parsed_request = params.require(:data).permit(:a, :b).to_h
  end

  def request_valid?
    params[:valid]
  end
end

describe Function do
  subject { Function.process(:index, request) }

  let(:request) { {data: {a: 1, b: 2, c: 3}, valid: true} }

  it "should return response object" do
    _(subject).must_equal({
      statusCode: 301,
      body:       {a: 1, b: 2}.to_json,
      headers:    {"Content-Type" => "application/json"}
    })
  end

  describe "when request is invalid" do
    let(:request) { {data: {a: 1, b: 2, c: 3}, valid: false} }

    it "should return 500 status response" do
      _(subject).must_equal({
        statusCode: 500,
        body:       "{}",
        headers:    {"Content-Type" => "application/json"}
      })
    end
  end
end
