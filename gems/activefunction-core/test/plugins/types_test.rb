# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

describe ActiveFunctionCore::Plugins::Types do
  subject { klass }

  let(:described_class) { ActiveFunctionCore::Plugins::Types }
  let(:klass) do
    Class.new { include ActiveFunctionCore::Plugins::Types }
  end

  describe "included" do
    it { _(subject).must_respond_to :define_schema }
    it { _(subject).must_respond_to :type }
    it { _(subject).must_respond_to :set_root_type }
  end

  describe "::type" do
    before do
      klass.type klass::NamedType => {string_attribute: String}
    end

    it "defines Constant < Type" do
      _(subject.const_defined?(:NamedType)).must_equal true
      _(subject.const_get(:NamedType)).must_be :<, described_class::Type
    end

    it "adds type to types" do
      _(subject.instance_variable_get(:@__types)).must_equal Set.new [subject::NamedType]
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
    before do
      klass.type klass::NamedType => {string_attribute: String}
      klass.set_root_type klass::NamedType
    end

    it "sets root type" do
      _(subject.instance_variable_get(:@__root_type_klass)).must_equal subject::NamedType
    end

    it "raises ArgumentError if provided class is not a Type | RawType" do
      invalid_klass = Class.new

      assert_raises(ArgumentError) { subject.set_root_type invalid_klass }
    end
  end

  describe "::define_schema" do
    before do
      klass.class_eval(&define_schema_proc)
    end

    let(:define_schema_proc) do
      ->(k) { define_schema { type k::NamedType => {string_attribute: String} } }
    end

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
    subject { klass.new(string_attribute: "string") }

    before do
      klass.type klass::NamedType => {string_attribute: String}
      klass.set_root_type klass::NamedType
    end

    it "creates instance of root type" do
      _(subject).must_be_instance_of klass::NamedType
    end

    it "raises ArgumentError if root type is not defined" do
      klass.instance_variable_set(:@__root_type_klass, nil)

      assert_raises(ArgumentError) { subject }
    end
  end
end
