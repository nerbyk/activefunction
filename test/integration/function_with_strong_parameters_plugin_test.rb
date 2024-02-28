# frozen_string_literal: true

require "test_helper"

ActiveFunction.config do
  plugin :strong_parameters
end

class FunctionWithStrongParameters < ActiveFunction::Base
  PERMITTED_PARAMS = [
    :id,
    user: [:name, :email],
    org:  [:id, :name, address: [:city, :street]]
  ]

  def index
    @response.body = request_body.permit(*PERMITTED_PARAMS).to_h
  end

  private def request_body = params.require(:body)
end

describe FunctionWithStrongParameters do
  subject { FunctionWithStrongParameters.process(:index, request) }

  let(:request) { {body: body} }

  let(:body) do
    {id: request_id, user: user_data, org: org_data}
  end

  let(:request_id) { 1 }
  let(:user_data) { {name: "Pupa", email: "pupa@acc.com"} }
  let(:org_data) { {id: 1, name: "ACC", address: address_data} }
  let(:address_data) { {city: "Moscow", street: "Lenina"} }

  let(:expected_response) do
    {
      statusCode: 200,
      headers:    {},
      body:       {
        id:   1,
        user: {name: "Pupa", email: "pupa@acc.com"},
        org:  {id: 1, name: "ACC", address: {city: "Moscow", street: "Lenina"}}
      }
    }
  end

  it "should return response object with permitted params" do
    _(subject).must_equal(expected_response)
  end

  describe "when request contains not permitted params" do
    before do
      request[:body][:user][:age] = 18
      request[:body][:org].merge! phone: "123456789"
    end

    it "should return response object with permitted params" do
      _(subject).must_equal(expected_response)
    end
  end

  describe "when request is invalid" do
    let(:request) { {no_body: false} }

    it "should raise error" do
      assert_raises { subject }
    end
  end
end
