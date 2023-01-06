require "test_helper"

class CoreTestFunction
  include ActiveFunction::Functions::Core

  def index
    nil
  end
end

class CoreTest < Minitest::Test

  def setup
    @function_class = CoreTestFunction
  end
  def test_process
    fn = @function_class.new(:index, {body: {}})

    assert_equal fn.instance_variable_get(:@action_name), :index
    assert_equal fn.instance_variable_get(:@request), {body: {}}
    assert_equal fn.instance_variable_get(:@performed), false
    assert_equal fn.instance_variable_get(:@response), { statusCode: 200, body: {}, headers: {} }

    mock = Minitest::Mock.new
    mock.expect(:call, nil)

    fn.stub(:index, mock) do
      fn.instance_variable_set(:@performed, true)
      fn.process
    end

    mock.verify
  end

  def test_process_raises_error_if_route_is_not_defined
    fn = @function_class.new(:show, {})

    assert_raises ActiveFunction::MissingRouteMethod do
      fn.instance_variable_set(:@performed, true)
      fn.process
    end
  end

  def test_process_raises_error_if_render_was_not_called
    fn = @function_class.new(:index, {})

    assert_raises ActiveFunction::NotRenderedError do
      fn.process
    end
  end
end
