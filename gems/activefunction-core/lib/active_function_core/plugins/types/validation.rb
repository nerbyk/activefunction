# frozen_string_literal: true

module ActiveFunctionCore::Plugins::Types
  module Validation
    module ValidationMethods
      class << self
        def type_validator_for(type)
          type = type.is_a?(Class) ? type : type.class

          if (primitive_type = PRIMITIVE_TYPE_VALIDATORS_MAPPING[type])
            primitive_type
          elsif type < RawType || type < Type
            method(:sub_type_validation)
          else
            raise ArgumentError, "unknown type #{type}"
          end
        end

        private

        def literal_type_validation(value, type_class)
          value.is_a?(type_class)
        end

        def boolean_type_validation(value, _type_class = nil)
          literal_type_validation(value, TrueClass) || literal_type_validation(value, FalseClass)
        end

        def array_type_validation(array, type_array)
          value_type           = type_array.first
          value_type_validator = type_validator_for(value_type)
          literal_type_validation(array, Array) && array.all? { |value| value_type_validator[value, value_type] }
        end

        def sub_type_validation(subtype_attributes, subtype_class)
          literal_type_validation(subtype_attributes, Hash) && (subtype_class < RawType || subtype_class < Type)
        end

        def nullable_type_validation(value, type_class)
          value.nil? || type_validator_for(type_class).call(value, type_class)
        end

        def hash_type_validation(value, type_hash)
          key_type, value_type           = type_hash.first
          key_validator, value_validator = [type_validator_for(key_type), type_validator_for(value_type)]
          literal_type_validation(value, Hash) && value.all? { |k, v| key_validator[k, key_type] && value_validator[v, value_type] }
        end

        def enum_type_validation(value, type_enum)
          type_enum.any? { |it| literal_type_validation(value, it) }
        end
      end

      def self.included(base)
        base.define_method(:type_validator_for, &method(:type_validator_for))
      end

      PRIMITIVE_TYPE_VALIDATORS_MAPPING = {
        String   => method(:literal_type_validation),
        Integer  => method(:literal_type_validation),
        Float    => method(:literal_type_validation),
        Symbol   => method(:literal_type_validation),
        Boolean  => method(:boolean_type_validation),
        Array    => method(:array_type_validation),
        Hash     => method(:hash_type_validation),
        Nullable => method(:nullable_type_validation),
        Enum     => method(:enum_type_validation)
      }

      private_constant :PRIMITIVE_TYPE_VALIDATORS_MAPPING
    end

    TypeValidator = Data.define(:value, :type) do
      include ValidationMethods

      def valid?
        if type.is_a?(CustomType) && type.wrapped_type
          validator_proc[value, type.wrapped_type]
        else
          validator_proc[value, type]
        end
      end

      private def validator_proc = type_validator_for(type)
    end
  end
end
