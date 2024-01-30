# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

class TestType
  include ActiveFunctionCore::Plugins::Types

  define_schema do
    type NamedType => {
      string_attribute:         String,
      integer_attribute:        Integer,
      boolean_attribute:        Boolean,
      array_attribute:          Array[String],
      hash_attribute:           Hash[Symbol, String],
      nested_type:              NestedType,
      array_nested_type:        Array[NestedType],
      hash_nested_type:         Hash[Symbol, NestedType],
      "?nullable_type":         String,
      alrenative_nullable_type: Nullable[Array[String]]
    }

    type NestedType => {
      nested_string_attribute:  String,
      nested_integer_attribute: Integer,
      sub_nested_type:          SubNestedType
    }

    type SubNestedType => {
      nested_nested_attribute: String
    }
  end
end

describe TestType do
  subject { TestType.new(attributes) }

  let(:attributes) do
    {
      string_attribute:  "string",
      integer_attribute: 1,
      boolean_attribute: true,
      array_attribute:   ["string"],
      hash_attribute:    {symbol: "string"},
      nested_type:       nested_type_attributes,
      array_nested_type: [nested_type_attributes],
      hash_nested_type:  {symbol: nested_type_attributes}
    }
  end

  let(:nested_type_attributes) do
    {
      nested_string_attribute:  "string",
      nested_integer_attribute: 1,
      sub_nested_type:          sub_nested_type_attributes
    }
  end

  let(:sub_nested_type_attributes) { {nested_nested_attribute: "string"} }

  let(:expected_attributes) { attributes.merge(expected_nullable_attributes) }
  let(:expected_nullable_attributes) { {nullable_type: nil, alrenative_nullable_type: nil} }

  it { _(subject).must_be_kind_of TestType::NamedType }
  it { _(subject.nested_type).must_be_kind_of TestType::NestedType }
  it { _(subject.nested_type.sub_nested_type).must_be_kind_of TestType::SubNestedType }

  it "should create typed object" do
    _(subject.to_h).must_equal expected_attributes
  end

  it "should create typed object with nullable attributes present" do
    nullable_present_attrs = {nullable_type: "string", alrenative_nullable_type: ["string"]}
    attributes.merge!(nullable_present_attrs)
    expected_attributes.merge!(nullable_present_attrs)

    _(subject.to_h).must_equal expected_attributes
  end

  describe "when nested type is invalid" do
    before do
      attributes[:nested_type][:sub_nested_type][:nested_nested_attribute] = 1
    end

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

  set_root_type NamedType
end

describe TestType2 do
  subject { TestType2.new({string_attribute: "string"}) }

  it "should create typed object" do
    assert_equal "string", subject.string_attribute
  end
end

class TestType3
  include ActiveFunctionCore::Plugins::Types

  define_schema do
    type NamedType => {
      string_attribute: String
    }

    set_root_type NamedType
  end
end

describe TestType3 do
  subject { TestType3.new(string_attribute: "string") }

  it "should create typed object" do
    assert_equal "string", subject.string_attribute
  end
end
