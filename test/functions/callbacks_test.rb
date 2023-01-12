# frozen_string_literal: true

require "test_helper"

class CallbackTestFunction
  include ActiveFunction::Functions::Core
  include ActiveFunction::Functions::Callbacks

  def index
    nil
  end

  def show
    nil
  end

  private # callback methods

  def first
    @first = "Biba"
  end

  def second
    @second = "Boba"
  end
end

class CallbackTestFunction1 < CallbackTestFunction
  set_callback :before, :first
end

class CallbackTest1 < Minitest::Test
  def setup
    @function = CallbackTestFunction1.new
  end

  def test_callback
    @function.dispatch(:index, {}, committed_response)

    assert_equal @function.instance_variable_get(:@first), "Biba"
  end
end

class CallbackTestFunction2 < CallbackTestFunction
  before_action :first
  after_action :second
end

class CallbackTest2 < Minitest::Test
  def setup
    @function = CallbackTestFunction2.new
  end

  def test_before_action_callback
    @function.dispatch(:index, {}, committed_response)

    assert_equal @function.instance_variable_get(:@first), "Biba"
  end

  def test_after_action_callback
    @function.dispatch(:index, {}, committed_response)

    assert_equal @function.instance_variable_get(:@second), "Boba"
  end
end

class ConditionalCallbacksTestFunction1 < CallbackTestFunction
  before_action :first, only: %i[index]
  after_action :second, only: %i[show]
end

class ConditionalCallbacksTest1 < Minitest::Test
  def setup
    @function = ConditionalCallbacksTestFunction1.new
  end

  def test_before_action_callback
    @function.dispatch(:index, {}, committed_response)

    assert_equal @function.instance_variable_get(:@first), "Biba"
    assert_nil @function.instance_variable_get(:@second)
  end

  def test_after_action_callback
    @function.dispatch(:show, {}, committed_response)

    assert_equal @function.instance_variable_get(:@second), "Boba"
  end
end

class ConditionalCallbacksTestFunction2 < CallbackTestFunction
  before_action :first, only: %i[show index]
end

class ConditionalCallbacksTest2 < Minitest::Test
  def setup
    @function = ConditionalCallbacksTestFunction2.new
  end

  def test_callback_for_index_action
    @function.dispatch(:index, {}, committed_response)

    assert_equal @function.instance_variable_get(:@first), "Biba"
  end

  def test_callback_for_show_action
    @function.dispatch(:show, {}, committed_response)

    assert_equal @function.instance_variable_get(:@first), "Biba"
  end
end

class ConditionalCallbacksTestFunction3 < CallbackTestFunction
  before_action :first, if: :executable?
  after_action :second, if: :not_executable?

  private

  def executable?
    false
  end

  def not_executable?
    true
  end
end

class ConditionalCallbacksTest3 < Minitest::Test
  def setup
    @function = ConditionalCallbacksTestFunction3.new
  end

  def test_if_before_action_callback
    @function.dispatch(:index, {}, committed_response)

    assert_nil @function.instance_variable_get(:@first)
    assert_equal @function.instance_variable_get(:@second), "Boba"
  end
end

class ConditionalCallbacksTestFunction4 < CallbackTestFunction
  before_action :first, only: %i[index], if: :executable?

  private def executable?
    true
  end
end

class ConditionalCallbacksTest4 < Minitest::Test
  def setup
    @function = ConditionalCallbacksTestFunction4.new
  end

  def test_callback_with_all_condition_options
    @function.dispatch(:index, {}, committed_response)

    assert_equal @function.instance_variable_get(:@first), "Biba"
  end
end
