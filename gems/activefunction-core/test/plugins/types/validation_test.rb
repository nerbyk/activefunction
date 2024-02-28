# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

module PrimitiveValidationTest
  TestClass = Class.new(ActiveFunctionCore::Plugins::Types::Validation::TypeValidator)

  def before_setup
    @attrs = {value: "Hello", type: String}
  end

  def test_string_validaiton
    assert @subject.valid?
  end

  def test_integer_validation
    @attrs = {value: 1, type: Integer}

    assert @subject.valid?
  end

  def test_float_validation
    @attrs = {value: 1.0, type: Float}

    assert @subject.valid?
  end

  def test_symbol_validation
    @attrs = {value: :hello, type: Symbol}

    assert @subject.valid?
  end

  def test_nullable_validation
    @attrs = {value: nil, type: ::ActiveFunctionCore::Plugins::Types::Nullable[String]}

    assert @subject.valid?
  end

  def test_boolean_validation
    @attrs = {value: true, type: ::ActiveFunctionCore::Plugins::Types::Boolean}

    assert @subject.valid?
  end

  def test_enum_validation
    @attrs = {value: "Hello", type: ::ActiveFunctionCore::Plugins::Types::Enum[String, Integer]}

    assert @subject.valid?
  end
end

class ValidationTest < Minitest::Test
  include PrimitiveValidationTest

  def setup
    @subject = TestClass.new(**@attrs)
  end
end

class ArrayValidationTest < Minitest::Test
  include PrimitiveValidationTest

  def setup
    @subject = TestClass.new(value: [@attrs[:value]], type: Array[@attrs[:type]])
  end
end

class HashValidationTest < Minitest::Test
  include PrimitiveValidationTest

  def setup
    @subject = TestClass.new(value: {key: @attrs[:value]}, type: Hash[Symbol => @attrs[:type]])
  end
end

class SubValidationTest < Minitest::Test
  include PrimitiveValidationTest

  def setup
    @subject = TestClass.new(value: {key: @attrs[:value]}, type: Hash[Symbol => @attrs[:type]])
  end
end
