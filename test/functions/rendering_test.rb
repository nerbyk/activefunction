# frozen_string_literal: true

require "test_helper"

class RenderingTestFunction
  include ActiveFunction::Functions::Core
  include ActiveFunction::Functions::Rendering

  def index
    render
  end
end

class RenderingTest < Minitest::Test
  def setup
    @function = RenderingTestFunction.new
  end

  def test_render_default_response
    @function.dispatch(:index, {}, response)

    response = @function.instance_variable_get(:@response)

    assert_equal response.status, 200
    assert_equal response.headers, {"Content-Type" => "application/json"}
    assert_equal response.body, "{}"
  end
end

class DoubleRenderTestFunction < RenderingTestFunction
  def index
    super
    render
  end
end

class DoubleRenderTest < Minitest::Test
  def setup
    @function = DoubleRenderTestFunction.new
  end

  def test_double_render
    assert_raises ActiveFunction::DoubleRenderError do
      @function.dispatch(:index, {}, response)
    end
  end
end

class RenderCustomResponseTestFunction < RenderingTestFunction
  def index
    render json: {a: 1, b: 2}, head: {"X-Test" => "test"}, status: 201
  end
end

class RenderCustomResponseTest < Minitest::Test
  def setup
    @function = RenderCustomResponseTestFunction.new
  end

  def test_render_custom_response
    @function.dispatch(:index, {}, response)

    response = @function.instance_variable_get(:@response)

    assert_equal response.status, 201
    assert_equal response.headers, {"Content-Type" => "application/json", "X-Test" => "test"}
    assert_equal response.body, '{"a":1,"b":2}'
  end
end

class NotRenderedTestFunction
  include ActiveFunction::Functions::Core
  include ActiveFunction::Functions::Rendering

  def index
    nil
  end
end

class NotRenderedTest < Minitest::Test
  def setup
    @function = NotRenderedTestFunction.new
  end

  def test_not_rendered
    assert_raises ActiveFunction::NotRenderedError do
      @function.dispatch(:index, {}, response)
    end
  end
end
