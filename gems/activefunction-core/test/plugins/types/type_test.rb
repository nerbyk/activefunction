# frozen_string_literal: true

require "test_helper"
require "active_function_core/plugins/types"

describe ActiveFunctionCore::Plugins::Types::Type do
  subject { described_class }

  let(:described_class) { ActiveFunctionCore::Plugins::Types::Type }
  let(:type_validator) { ActiveFunctionCore::Plugins::Types::TypeValidation::TypeValidator }

  it { _(subject).must_be(:<, ::Data) }
  it { _(subject).must_respond_to(:define) }

  describe ".define" do
    subject { type_klass }

    let(:type_klass) { described_class.define(type_validator: type_validator, **schema) }
    let(:schema) { {str: String, int: Integer} }

    it { _(subject).must_respond_to(:schema) }

    it "defines Type Data class with provided schema" do
      _(subject.schema).must_equal(schema)
      _(subject.members).must_equal(schema.keys)
    end

    describe ".new" do
      subject { type_klass.new(**attributes) }

      let(:attributes) { {str: "string", int: 1} }

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

      describe "Integer type" do
        let(:schema) { {int: Integer} }
        let(:attributes) { {int: 1} }

        it "accepts Integer" do
          _(subject.int).must_equal(attributes[:int])
        end

        it "raises TypeError if provided attribute type doesn't match" do
          attributes[:int] = "string"

          assert_raises(TypeError) { subject }
        end
      end

      describe "String type" do
        let(:schema) { {str: String} }
        let(:attributes) { {str: "string"} }

        it "accepts String" do
          _(subject.str).must_equal(attributes[:str])
        end

        it "raises TypeError if provided attribute type doesn't match" do
          attributes[:str] = 1

          assert_raises(TypeError) { subject }
        end
      end

      describe "Boolean type" do
        let(:schema) { {bool: ActiveFunctionCore::Plugins::Types::Boolean} }
        let(:attributes) { {bool: true} }

        it "accepts Boolean" do
          _(subject.bool).must_equal(attributes[:bool])
        end

        it "raises TypeError if provided attribute type doesn't match" do
          attributes[:bool] = 1

          assert_raises(TypeError) { subject }
        end
      end

      describe "Array type" do
        let(:schema) { {arr: Array[String]} }
        let(:attributes) { {arr: ["string"]} }

        it "accepts Array" do
          _(subject.arr).must_equal(attributes[:arr])
        end

        it "raises TypeError if provided attribute type doesn't match" do
          attributes[:arr] = [1]

          assert_raises(TypeError) { subject }
        end
      end

      describe "Hash type" do
        let(:schema) { {hash_attr: Hash[Symbol, String]} }
        let(:attributes) { {hash_attr: {symbol: "string"}} }

        it "accepts Hash" do
          _(subject.to_h).must_equal(attributes)
        end

        it "raises TypeError if provided attribute type doesn't match" do
          attributes[:hash_attr] = {symbol: 1}

          assert_raises(TypeError) { subject }
        end
      end

      describe "Nested type" do
        let(:nested_type) { Nested = described_class.define(type_validator: type_validator, **nested_schema) }
        let(:nested_schema) { {nested: String} }

        let(:schema) { {nested_type: nested_type} }

        let(:nested_attributes) { {nested: "string"} }
        let(:attributes) { {nested_type: nested_attributes} }

        it "accepts nested type" do
          _(subject.nested_type.to_h).must_equal(nested_attributes)
        end

        it "raises TypeError if provided attribute type doesn't match" do
          nested_attributes[:nested] = 1

          assert_raises(TypeError) { subject }
        end
      end
    end
  end
end
