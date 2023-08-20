# frozen_string_literal: true

require "test_helper"

class CoreTestFunction
  include ActiveFunction::Functions::Core

  def index
    nil
  end
end

class CoreTest < Minitest::Test
  def setup
    @function = CoreTestFunction.new
  end

  def test_action_to_be_called
    mock = Minitest::Mock.new
    mock.expect(:call, nil)

    @function.stub(:index, mock) do
      @function.dispatch(:index, {body: {}}, committed_response)
    end

    mock.verify
  end

  def test_dispatch_raises_error_if_route_is_not_defined
    assert_raises ActiveFunction::MissingRouteMethod do
      @function.dispatch(:show, {}, response)
    end
  end

  def test_dispatch_raises_error_if_render_was_not_called
    assert_raises ActiveFunction::NotRenderedError do
      @function.dispatch(:index, {}, response)
    end
  end
end
