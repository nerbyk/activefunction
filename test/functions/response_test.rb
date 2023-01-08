require "test_helper"

class ResponseTest < Minitest::Test
  def setup
    @response = ActiveFunction::Functions::Response.new
  end

  def test_status
    @response.status = 201

    assert_equal @response.status, 201
  end

  def test_headers
    @response.headers = {"X-Test" => "test"}

    assert_equal @response.headers, {"X-Test" => "test"}
  end

  def test_body
    @response.body = "test"

    assert_equal @response.body, "test"
  end

  def test_to_h
    @response.status  = 201
    @response.headers = {"X-Test" => "test"}
    @response.body    = "test"

    assert_equal @response.to_h, {statusCode: 201, headers: {"X-Test" => "test"}, body: "test"}
  end
end
