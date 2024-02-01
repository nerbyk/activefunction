# frozen_string_literal: true

module ActiveFunctionCore::Plugins::Types
  CustomType = Struct.new(:wrapped_type)
  Boolean    = Class.new(CustomType)
  Nullable   = Class.new(CustomType)

  class Type < Data
    def self.define(type_validator:, **attributes, &block)
      nillable_attributes = handle_nillable_attributes!(attributes)

      super(*attributes.keys, &block).tap do |klass|
        klass.define_singleton_method(:schema) { attributes.freeze }
        klass.define_singleton_method(:nillable_members) { nillable_attributes }
        klass.define_method(:type_validator) { type_validator }
      end
    end

    private_class_method def self.handle_nillable_attributes!(attributes)
      attributes.keys.lazy
        .select { |key| key.to_s.start_with?("?") || attributes[key].is_a?(Nullable) }
        .map do |key|
          next key unless key.to_s.start_with?("?")

          normalized_key             = key.to_s.delete_prefix("?").to_sym
          attributes[normalized_key] = Nullable[attributes.delete(key)]
          normalized_key
        end
        .to_a
    end

    def initialize(attributes)
      if (missing_nil_attributes = self.class.nillable_members - attributes.keys).any?
        attributes.merge! missing_nil_attributes.product([nil]).to_h
      end

      super(**_build_attributes!(attributes))
    end

    def to_h
      super.map do |k, v|
        hashed_subtypes = _process_subtype_values(schema[k], v) { _2.to_h }
        [k, hashed_subtypes]
      end.to_h
    end

    def schema = self.class.schema

    private

    def _subtype?(type)
      type.is_a?(Class) && (type < RawType || type < Type)
    end

    def _subtype_class(type)
      self.class.const_get(type.name)
    end

    def _build_attributes!(attributes)
      attributes.map(&method(:_prepare_attribute)).to_h
    end

    def _prepare_attribute(name, value)
      raise ArgumentError, "unknown attribute #{name}" unless (type = schema[name])
      raise(TypeError, "expected #{value} to be a #{type}") unless type_validator[value, type].valid?

      serialized_value = _process_subtype_values(type, value) { |subtype, attrs| subtype[**attrs] }

      [name, serialized_value]
    end

    def _process_subtype_values(type, value, &block)
      if _subtype?(type)
        yield _subtype_class(type), value
      elsif type.is_a?(Array) && _subtype?(type.first)
        value.map { |it| yield(_subtype_class(type.first), it) }
      elsif type.is_a?(Hash) && _subtype?(type.values.first)
        value.transform_values { |it| yield(_subtype_class(type.values.first), it) }
      else
        value
      end
    end
  end
end
