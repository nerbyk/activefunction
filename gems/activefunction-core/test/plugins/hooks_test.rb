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
    assert_equal @res.dig(:salaries, :pupa), {name: "Lupa", amount: 100} # pupa gets lupa's salary
  end
end

class CallbackTestClass2 < HooksSetupClass
  before_payout :set_pupa_salary
  after_payout :set_lupa_salary
end

class CallbackTest2 < Minitest::Test
  def setup
    @obj      = CallbackTestClass2.new
    @response = @obj.payout
  end

  def test_before_action_callback
    assert_equal @response.dig(:salaries, :pupa), {name: "Lupa", amount: 100}
  end

  def test_after_action_callback
    assert_equal @response.dig(:salaries, :lupa), nil
    assert_equal @obj.instance_variable_get(:@lupa_salary), {name: "Pupa", amount: 200}
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

    assert_equal @response.dig(:salaries, :pupa), {name: "Lupa", amount: 100}
    assert_equal @response.dig(:salaries, :lupa), nil
    assert_equal @obj.instance_variable_get(:@lupa_salary), {name: "Pupa", amount: 200}
  end

  def test_iherit_callback_uniqness
    assert_equal @obj.class.hooks[:payout].before.callbacks.size, 1

    @obj.class.before_payout :set_pupa_salary # duplicate callback

    assert_equal @obj.class.hooks[:payout].before.callbacks.size, 1
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
    assert_equal @obj.instance_variable_get(:@pupa_salary), {name: "Lupa", amount: 100}
  end
end
