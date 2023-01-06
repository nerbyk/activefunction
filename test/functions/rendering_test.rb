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
    @function = RenderingTestFunction.new(:index, {})
  end

  def test_render_default_response
    @function.process

    assert_equal @function.instance_variable_get(:@response)[:statusCode], 200
    assert_equal @function.instance_variable_get(:@response)[:headers], {"Content-Type" => "application/json"}
    assert_equal @function.instance_variable_get(:@response)[:body], "{}"
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
    @function = DoubleRenderTestFunction.new(:index, {})
  end

  def test_double_render
    assert_raises ActiveFunction::DoubleRenderError do
      @function.process
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
    @function = RenderCustomResponseTestFunction.new(:index, {})
  end

  def test_render_custom_response
    @function.process

    assert_equal  @function.instance_variable_get(:@response)[:statusCode], 201
    assert_equal  @function.instance_variable_get(:@response)[:headers], {"Content-Type" => "application/json", "X-Test" => "test"}
    assert_equal  @function.instance_variable_get(:@response)[:body], '{"a":1,"b":2}'
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
    @function = NotRenderedTestFunction.new(:index, {})
  end

  def test_not_rendered
    assert_raises ActiveFunction::NotRenderedError do
      @function.process
    end
  end
end
