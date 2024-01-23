# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

class TestType
  include ActiveFunctionCore::Plugins::Types

  define_schema(NamedType) do
    type NamedType => {
      string_attribute:  String,
      integer_attribute: Integer,
      boolean_attribute: Boolean,
      array_attribute:   Array[String],
      hash_attribute:    Hash[Symbol, String],
      nested_type:       NestedType
    }

    type NestedType => {
      nested_string_attribute:  String,
      nested_integer_attribute: Integer,
      nested_nested_type:       AllTypesNested
    }

    type AllTypesNested => {
      nested_nested_attribute: String
    }
  end
end

describe TestType do
  let(:root_attributes) do
    {
      string_attribute:  string_attribute,
      integer_attribute: integer_attribute,
      boolean_attribute: boolean_attribute,
      array_attribute:   array_attribute,
      hash_attribute:    hash_attribute,
      nested_type:       nested_type_attributes
    }
  end

  let(:nested_type_attributes) do
    {
      nested_string_attribute:  nested_string_attribute,
      nested_integer_attribute: nested_integer_attribute,
      nested_nested_type:       nested_nested_type_attributes
    }
  end

  let(:nested_nested_type_attributes) do
    {
      nested_nested_attribute: nested_nested_attribute
    }
  end

  let(:string_attribute) { "string" }
  let(:integer_attribute) { 1 }
  let(:boolean_attribute) { true }
  let(:array_attribute) { ["string"] }
  let(:hash_attribute) { {symbol: "string"} }
  let(:nested_string_attribute) { "string" }
  let(:nested_integer_attribute) { 1 }
  let(:nested_nested_attribute) { "string" }

  subject { TestType.new(**root_attributes) }

  it "should create typed object" do
    assert_equal string_attribute, subject.string_attribute
    assert_equal integer_attribute, subject.integer_attribute
    assert_equal boolean_attribute, subject.boolean_attribute
    assert_equal array_attribute, subject.array_attribute
    assert_equal hash_attribute, subject.hash_attribute
    assert_equal nested_string_attribute, subject.nested_type.nested_string_attribute
    assert_equal nested_integer_attribute, subject.nested_type.nested_integer_attribute
    assert_equal nested_nested_attribute, subject.nested_type.nested_nested_type.nested_nested_attribute
  end

  describe "when nested type is invalid" do
    let(:nested_integer_attribute) { "string" }

    it "should raise error" do
      assert_raises(TypeError) { subject }
    end
  end
end

class TestType2
  include ActiveFunctionCore::Plugins::Types

  type NamedType => {
    string_attribute: String
  }

  root_type_klass NamedType
end

describe TestType2 do
  subject { TestType2.new(string_attribute: "string") }

  it "should create typed object" do
    assert_equal "string", subject.string_attribute
  end
end

class TestType3
  include ActiveFunctionCore::Plugins::Types

  type self: {
    string_attribute: String
  }
end

describe TestType3 do
  subject { TestType3.new(string_attribute: "string") }

  it "should create typed object" do
    assert_equal "string", subject.string_attribute
  end
end

class TestType4
  include ActiveFunctionCore::Plugins::Types

  define_schema do
    type self: {
      string_attribute: String
    }
  end
end

describe TestType4 do
  subject { TestType4.new(string_attribute: "string") }

  it "should create typed object" do
    assert_equal "string", subject.string_attribute
  end
end

class TestType5
  include ActiveFunctionCore::Plugins::Types

  define_schema do
    type NamedType => {
      string_attribute: String
    }

    root_type_klass NamedType
  end
end

describe TestType5 do
  subject { TestType5.new(string_attribute: "string") }

  it "should create typed object" do
    assert_equal "string", subject.string_attribute
  end
end
