# frozen_string_literal: true

module ActiveFunctionCore::Plugins::Types
  CustomType = Struct.new(:wrapped_type)
  Boolean    = Class.new(CustomType)
  Nullable   = Class.new(CustomType)

  class Type < Data
    def self.define(type_validator:, **attributes, &block)
      nillable_attributes = attributes.map do |k, v|
        if k.start_with?("?")
          normalized_key = k.to_s.gsub(/^\?/, "").to_sym
          [normalized_key, Nullable[v]]
        else
          [k, v]
        end
      end.to_h

      attributes.merge!(nillable_attributes)

      super(*attributes.keys, &block).tap do |klass|
        klass.define_singleton_method(:schema) { attributes.freeze }
        klass.define_singleton_method(:nillable_members) { nillable_attributes.keys }
        klass.define_method(:type_validator) { type_validator }
      end
    end

    def initialize(attrs)
      super(**build_attributes!(attrs))
    end

    def to_h
      super.map do |k, v|
        hashed_subtypes = process_subtype_values(schema[k], v) { _2.to_h }
        [k, hashed_subtypes]
      end.to_h
    end

    def schema = self.class.schema

    private

    def subtype?(type)
      type.is_a?(Class) && (type < RawType || type < Type)
    end

    def subtype_class(type)
      self.class.const_get(type.name)
    end

    def build_attributes!(attributes)
      if (missing_nil_attributes = self.class.nillable_members - attributes.keys).any?
        attributes.merge! missing_nil_attributes.product([nil]).to_h
      end

      attributes.map(&method(:prepare_attribute)).to_h
    end

    def prepare_attribute(name, value)
      raise ArgumentError, "unknown attribute #{name}" unless (type = schema[name])
      raise(TypeError, "expected #{value} to be a #{type}") unless type_validator[value, type].valid?

      serialized_value = process_subtype_values(type, value) { |subtype, attrs| subtype[**attrs] }

      [name, serialized_value]
    end

    def process_subtype_values(type, value, &block)
      if subtype?(type)
        yield subtype_class(type), value
      elsif type.is_a?(Array) && subtype?(type[0])
        value.map { |it| yield(subtype_class(type[0]), it) }
      elsif type.is_a?(Hash) && subtype?(type.values[0])
        value.transform_values { |it| yield(subtype_class(type.values[0]), it) }
      else
        value
      end
    end
  end
end
