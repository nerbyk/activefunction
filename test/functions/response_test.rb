# frozen_string_literal: true

require "test_helper"

class ResponseTest < Minitest::Test
  def setup
    @response = ActiveFunction::Functions::Response::Response.new
  end

  def test_status
    @response.status = 201

    assert_equal 201, @response.status
  end

  def test_headers
    @response.headers = {"X-Test" => "test"}

    assert_equal({"X-Test" => "test"}, @response.headers)
  end

  def test_body
    @response.body = "test"

    assert_equal "test", @response.body
  end

  def test_to_h
    @response.status  = 201
    @response.headers = {"X-Test" => "test"}
    @response.body    = "test"

    assert_equal({statusCode: 201, headers: {"X-Test" => "test"}, body: "test"}, @response.to_h)
  end

  def test_commit!
    assert_equal false, @response.committed?

    @response.commit!

    assert_equal true, @response.committed?
  end
end
