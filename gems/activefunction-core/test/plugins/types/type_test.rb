# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

describe ActiveFunctionCore::Plugins::Types::Type do
  subject { described_class }

  let(:described_class) { ActiveFunctionCore::Plugins::Types::Type }
  let(:type_validator) { ActiveFunctionCore::Plugins::Types::Validation::TypeValidator }

  it { _(subject).must_be(:<, ::Data) }
  it { _(subject).must_respond_to(:define) }

  describe ".define" do
    subject { type_klass }

    let(:type_klass) { described_class.define(type_validator: type_validator, **schema) }
    let(:schema) { {str: String, int: Integer} }
    let(:attributes) { {str: "string", int: 1} }

    it { _(subject).must_respond_to(:schema) }

    it "defines Type Data class with provided schema" do
      _(subject.schema).must_equal(schema)
      _(subject.members).must_equal(schema.keys)
    end

    describe "when nullable ?attribute is provided" do
      before do
        schema.merge!("?nullable": String, nullable2: ActiveFunctionCore::Plugins::Types::Nullable[String])
      end

      it "defines Type Data class with nillable members" do
        _(subject.members).must_equal %i[str int nullable2 nullable]
        _(subject.nillable_members).must_equal %i[nullable nullable2]
      end
    end

    describe ".new" do
      subject { type_klass.new(**attributes) }

      it "creates instance Data instance with typed members" do
        _(subject.str).must_equal(attributes[:str])
        _(subject.int).must_equal(attributes[:int])
      end

      it "raises TypeError if provided attribute type doesn't match" do
        attributes[:str] = 1

        assert_raises(TypeError) { subject }
      end

      it "raises ArgumentError if provided attribute is not defined in schema" do
        attributes[:unknown] = nil

        assert_raises(ArgumentError) { subject }
      end
    end

    describe "#to_h" do
      subject { type_klass.new(**attributes).to_h }

      it "returns hash with typed members" do
        _(subject).must_equal(attributes)
      end

      describe "when schema contains nested types" do
        let(:schema) { {str: String, nested: nested_type} }
        let(:nested_type) { NestedType = described_class.define(type_validator: type_validator, nested_str: String) }
        let(:attributes) { {str: "string", nested: {nested_str: "string"}} }

        it "returns hash with nested types" do
          _(subject).must_equal(attributes)
        end
      end
    end
  end
end
