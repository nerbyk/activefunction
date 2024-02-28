# frozen_string_literal: true

module ActiveFunctionCore
  module Plugins
    module Types
      require "active_function_core/plugins/types/type"
      require "active_function_core/plugins/types/validation"

      RawType = Class.new

      module ClassMethods
        def const_missing(name)
          super unless @__root_type_klass.nil?

          ActiveFunctionCore.logger.warn "Constant #{name} is missing. Defining Constant #{name} as a RawType." unless @__save_schema_definition

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
          klass, attributes = hash_attr.first

          raise ArgumentError, "type Class must be a RawType" unless klass < RawType

          type_name       = klass.name.split("::").last.to_sym
          type_attributes = attributes.is_a?(Hash) ? Type.define(**attributes) : attributes

          remove_const(type_name).tap do
            (@__types ||= Set.new) << const_set(type_name, type_attributes)
          end
        end

        def set_root_type(type)
          raise(ArgumentError, "Unknown type class #{type}") unless @__types === type

          @__root_type_klass = type
        end

        def new(hash_attrs)
          raise ArgumentError, "Root type is not defined." unless @__root_type_klass

          @__root_type_klass.new(**hash_attrs)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
