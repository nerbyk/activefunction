# frozen_string_literal: true

require "test_helper"

class IvalidSalaryClass
  Salary = Data.define(:name, :amount)

  def payout
    {
      salaries: {
        pupa: @pupa_salary,
        lupa: @lupa_salary
      }
    }
  end

  private

  def set_pupa_salary
    @pupa_salary = Salary[name: "Lupa", amount: 100].to_h
  end

  def set_lupa_salary
    @lupa_salary = Salary[name: "Pupa", amount: 200].to_h
  end
end

class HooksSetupClass < IvalidSalaryClass
  include ActiveFunctionCore::Plugins::Hooks

  define_hooks_for :payout
end

class CallbackTestClass1 < HooksSetupClass
  set_callback :before, :payout, :set_pupa_salary
end

class CallbackTest1 < Minitest::Test
  def setup
    @res = CallbackTestClass1.new.payout
  end

  def test_callback
    assert_equal({name: "Lupa", amount: 100}, @res.dig(:salaries, :pupa)) # pupa gets lupa's salary
  end
end

class CallbackTestClass2 < HooksSetupClass
  before_payout :set_pupa_salary
  after_payout :set_lupa_salary
end

class CallbackTest2 < Minitest::Test
  def setup
    @obj = CallbackTestClass2.new
    @response = @obj.payout
  end

  def test_before_action_callback
    assert_equal({name: "Lupa", amount: 100}, @response.dig(:salaries, :pupa))
  end

  def test_after_action_callback
    assert_nil @response.dig(:salaries, :lupa)
    assert_equal({name: "Pupa", amount: 200}, @obj.instance_variable_get(:@lupa_salary))
  end
end

class CallbackTestClass3 < HooksSetupClass
  set_callback :before, :payout, :set_lupa_salary
end

class CallbackTest3 < Minitest::Test
  def setup
    @obj = CallbackTestClass3.new
  end

  def response = @obj.payout

  def test_set_callback_method
    response
    assert_equal({name: "Pupa", amount: 200}, @obj.instance_variable_get(:@lupa_salary))
  end

  def test_set_callback_missing_method
    @obj.class.set_callback :before, :payout, :missing_method

    assert_raises ActiveFunctionCore::Plugins::Hooks::MissingCallbackContext do
      response
    end

    @obj.class.hooks[:payout].callbacks[:before].delete_at(-1)
  end
end

class CallbackTestClass2Inherit < CallbackTestClass2
end

class CallbackTest2Inherit < Minitest::Test
  def setup
    @obj = CallbackTestClass2Inherit.new
  end

  def test_inherit_callbacks
    @response = @obj.payout

    assert_equal({name: "Lupa", amount: 100}, @response.dig(:salaries, :pupa))
    assert_nil @response.dig(:salaries, :lupa)
    assert_equal({name: "Pupa", amount: 200}, @obj.instance_variable_get(:@lupa_salary))
  end

  def test_iherit_callback_uniqness
    assert_equal 1, @obj.class.hooks[:payout].before.size

    assert_raises ArgumentError do
      @obj.class.before_payout :set_pupa_salary # duplicate callback
    end

    assert_equal 1, @obj.class.hooks[:payout].before.size
  end

  def test_iherit_callback_hooks_object_id
    refute_equal @obj.class.hooks.object_id, CallbackTestClass2.new.class.hooks.object_id
  end
end

class ConditionalCallbacksTestClass3 < HooksSetupClass
  before_payout :set_lupa_salary, if: :executable?
  after_payout :set_pupa_salary, if: :not_executable?

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
    @obj = ConditionalCallbacksTestClass3.new
    @obj.payout
  end

  def test_if_before_action_callback
    assert_nil @obj.instance_variable_get(:@lupa_salary)
    assert_equal({name: "Lupa", amount: 100}, @obj.instance_variable_get(:@pupa_salary))
  end
end
