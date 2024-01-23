# frozen_string_literal: true

module ActiveFunctionCore
  module Plugins
    module Types
      Boolean = Class.new
      RawType = Class.new

      LetiralTypeValidation = proc { |value, type| value.is_a?(type) }
      BooleanTypeValidation = proc { |value| LetiralTypeValidation[value, TrueClass] || LetiralTypeValidation[value, FalseClass] }
      ArrayTypeValidation   = proc { |value, type| LetiralTypeValidation[value, Array] && value.all? { |v| LetiralTypeValidation[v, type[0]] } }
      SubTypeValidation     = proc { |value, type| LetiralTypeValidation[value, Hash] && (type < RawType || type < Type) }
      HashTypeValidation    = proc do |value, type|
        k_type, v_type = type.first
        LetiralTypeValidation[value, Hash] && value.all? { |k, v| k.is_a?(k_type) && v.is_a?(v_type) }
      end

      class Type < Data
        VALIDATORS = {
          String    => LetiralTypeValidation,
          Integer   => LetiralTypeValidation,
          Float     => LetiralTypeValidation,
          Symbol    => LetiralTypeValidation,
          Boolean   => BooleanTypeValidation,
          Array     => ArrayTypeValidation,
          Hash      => HashTypeValidation,
          :sub_type => SubTypeValidation
        }

        TypeError = Class.new(::TypeError)

        def self.define(**attributes, &block)
          super(*attributes.keys, &block).tap do |klass|
            klass.define_singleton_method(:schema) { attributes.freeze }
          end
        end

        def initialize(**attributes)
          attributes.each { |it| validate_type!(it) }

          subtype_attrs = attributes
            .filter { |name, _| schema[name].is_a?(Class) && subtype_klass(name) < Type }
            .each_with_object({}) { |(name, value), h| h[name] = subtype_klass(name).new(**value) }

          super(**attributes.merge(subtype_attrs))
        end

        def schema = self.class.schema

        private

        def subtype_klass(name)
          return schema[name] unless schema[name].is_a?(Class) && schema[name] < RawType

          self.class.const_get(schema[name].name)
        end

        def validate_type!(type_definition)
          name, value = type_definition
          type        = schema[name].is_a?(Class) ? schema[name] : schema[name].class

          validator = VALIDATORS[type] || VALIDATORS[:sub_type]

          return if validator.call(value, schema[name])

          raise TypeError, "expected #{name} to be a #{schema[name]}, got #{value.class}"
        end
      end

      module ClassMethods
        def const_missing(name)
          super unless @__root_type_klass.nil?

          const_set(name, Class.new(RawType))
        end

        def define_schema(root = nil, &block)
          class_eval(&block)

          if root.nil?
            raise ArgumentError, "root type is not defined within a block" if @__root_type_klass.nil?
          else
            @__root_type_klass = const_get(root.name)
          end
        end

        def type(hash)
          klass, attributes = hash.first

          if klass == :self
            raise ArgumentError, "root type is already defined" if @__root_type_klass

            @__root_type_klass = Type.define(**attributes)
          else
            raise ArgumentError, "type Class must be a RawType" unless klass < RawType

            name = klass.name.split("::").last
            remove_const(name.to_sym)

            const_set(name, Type.define(**attributes))
          end
        end

        def root_type_klass(type)
          raise(ArgumentError, "Unknown type class #{type}") unless defined?(type) || (type < RawType || type < Type)

          @__root_type_klass = type
        end

        def new(**attributes)
          raise ArgumentError, "root type is not defined" unless @__root_type_klass

          @__root_type_klass.new(**attributes)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
