# frozen_string_literal: true

module ActiveFunctionCore
  module Plugins
    module Types
      Boolean = Class.new
      RawType = Class.new

      LetiralTypeValidation = proc { |value, type| value.is_a?(type) }
      BooleanTypeValidation = proc { |value| LetiralTypeValidation[value, TrueClass] || LetiralTypeValidation[value, FalseClass] }
      ArrayTypeValidation   = proc { |value, type| LetiralTypeValidation[value, Array] && value.all? { |v| TypeValidator[type[0]].call(v, type[0]) } }
      SubTypeValidation     = proc { |value, type| type.is_a?(Class) && LetiralTypeValidation[value, Hash] && (type < RawType || type < Type) }
      HashTypeValidation    = proc do |value, type|
        k_type, v_type           = type.first
        k_validator, v_validator = [TypeValidator[k_type], TypeValidator[v_type]]
        LetiralTypeValidation[value, Hash] && value.all? { |k, v| k_validator[k, k_type] && v_validator[v, v_type] }
      end

      VALIDATORS_MAPPING = {
        String    => LetiralTypeValidation,
        Integer   => LetiralTypeValidation,
        Float     => LetiralTypeValidation,
        Symbol    => LetiralTypeValidation,
        Boolean   => BooleanTypeValidation,
        Array     => ArrayTypeValidation,
        Hash      => HashTypeValidation,
        :sub_type => SubTypeValidation
      }

      TypeValidator = proc do |type|
        type_klass = type.is_a?(Class) ? type : type.class

        VALIDATORS_MAPPING[type_klass] || VALIDATORS_MAPPING[:sub_type]
      end

      class Type < Data
        def self.define(**attributes, &block)
          super(*attributes.keys, &block).tap do |klass|
            klass.define_singleton_method(:schema) { attributes.freeze }
          end
        end

        def initialize(**attributes)
          super(**attributes.then(&method(:prepare_attributes!)))
        end

        def schema = self.class.schema

        private

        def prepare_attributes!(attributes)
          attributes.each_with_object({}) do |(name, value), h|
            raise ArgumentError, "unknown attribute #{name}" unless (type = schema[name])
            raise(TypeError, "expected #{value} to be a #{type}") unless TypeValidator[type].call(value, type)

            h[name] = transform_attribute(type, value)
          end
        end

        def transform_attribute(type, value)
          if type.is_a?(Class) && (type < RawType || type < Type)
            self.class.const_get(type.name).new(**value)
          else
            value
          end
        end
      end

      module ClassMethods
        extend Forwardable
        def_delegator ActiveFunctionCore.logger, :warn

        def const_missing(name)
          super unless @__root_type_klass.nil?

          warn "Constant #{name} is missing. Defining Constant #{name} as a RawType" unless @__save_schema_definition

          const_set(name, Class.new(RawType))
        end

        def define_schema(&block)
          @__save_schema_definition = true

          class_eval(&block)

          raise ArgumentError, "no types defined" unless @__types

          @__types.freeze
          set_root_type(@__types.first) if @__root_type_klass.nil?
          @__save_schema_definition = false
        end

        def type(hash_attr)
          @__types        ||= Set.new
          klass, attributes = hash_attr.first

          raise ArgumentError, "type Class must be a RawType" unless klass < RawType

          name = klass.name.split("::").last
          remove_const(name.to_sym)

          @__types << const_set(name, Type.define(**attributes))
        end

        def set_root_type(type)
          raise(ArgumentError, "Unknown type class #{type}") unless @__types === type

          @__root_type_klass = type
        end

        def new(**attributes)
          raise ArgumentError, "Root type is not defined." unless @__root_type_klass

          @__root_type_klass.new(**attributes)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
