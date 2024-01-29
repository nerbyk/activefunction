# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

describe ActiveFunctionCore::Plugins::Types do
  class TypesIncludedTestClass
    include ActiveFunctionCore::Plugins::Types
  end

  subject { klass }

  let(:klass) { TypesIncludedTestClass }
  let(:described_class) { ActiveFunctionCore::Plugins::Types }

  describe "included" do
    it { _(subject).must_respond_to :define_schema }
    it { _(subject).must_respond_to :type }
    it { _(subject).must_respond_to :set_root_type }
  end

  describe "::type" do
    class TypeTestClass < TypesIncludedTestClass
      type NamedType => {
        string_attribute: String
      }
    end

    let(:klass) { TypeTestClass }

    it "defines Constant < Type" do
      _(subject.const_defined?(:NamedType)).must_equal true
      _(subject.const_get(:NamedType)).must_be :<, described_class::Type
    end

    it "adds type to types" do
      _(subject.instance_variable_get(:@__types)).must_be :===, subject::NamedType
    end

    it "redefines RawType to Type" do
      klass.class_eval { TestRawType = Class.new(ActiveFunctionCore::Plugins::Types::RawType) }

      _(klass::TestRawType).must_be :<, subject::RawType

      klass.type klass::TestRawType => {string_attribute: String}

      _(klass::TestRawType).must_be :<, subject::Type
    end

    it "raises ArgumentError if type Class is not a RawType" do
      invalid_klass = Class.new

      assert_raises(ArgumentError) { klass.type invalid_klass => {string_attribute: String} }
    end
  end

  describe "::set_root_type" do
    class TestSetRootTypeClass < TypesIncludedTestClass
      type NamedType => {
        string_attribute: String
      }

      set_root_type NamedType
    end

    let(:klass) { TestSetRootTypeClass }

    it "sets root type" do
      _(subject.instance_variable_get(:@__root_type_klass)).must_equal subject::NamedType
    end

    it "raises ArgumentError if provided class is not a Type | RawType" do
      invalid_klass = Class.new

      assert_raises(ArgumentError) { subject.set_root_type invalid_klass }
    end
  end

  describe "::define_schema" do
    class TestDefineSchemaClass < TypesIncludedTestClass
      define_schema do
        type NamedType => {
          string_attribute: String
        }
      end
    end

    let(:klass) { TestDefineSchemaClass }

    it "sets root type" do
      _(subject.instance_variable_get(:@__root_type_klass)).must_equal subject::NamedType
    end

    it "freezes types" do
      _(subject.instance_variable_get(:@__types)).must_be :frozen?
    end

    it "raises ArgumentError if no types defined" do
      assert_raises(ArgumentError) { klass.define_schema }
    end
  end

  describe "::new" do
    class TestNewClassWithRootType < TypesIncludedTestClass
      type NamedType => {
        string_attribute: String
      }

      set_root_type NamedType
    end

    class TestNewClassWithoutRootType < TypesIncludedTestClass
      type NamedType => {
        string_attribute: String
      }
    end

    subject do
      klass.new({string_attribute: "string"})
    end

    let(:klass) { TestNewClassWithRootType }

    it "creates instance of root type" do
      _(subject).must_be_instance_of klass::NamedType
    end

    it "raises ArgumentError if root type is not defined" do
      assert_raises(ArgumentError) { TestNewClassWithoutRootType.new(string_attribute: "string") }
    end
  end
end
