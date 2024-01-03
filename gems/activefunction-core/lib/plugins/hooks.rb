# frozen_string_literal: true

require "forwardable"

module ActiveFunctionCore
  module Plugins
    module Hooks
      TYPES = %i[before after].freeze

      class MissingCallbackContext < Error
        MESSAGE_TEMPLATE = "Missing callback context: %s"

        def initialize(context) = super(MESSAGE_TEMPLATE % context)
      end

      class MissingHookableMethod < Error
        MESSAGE_TEMPLATE = "Method %s is not defined"

        def initialize(method_name) = super(MESSAGE_TEMPLATE % method_name)
      end

      class HookedMethodArgumentError < Error
        MESSAGE_TEMPLATE = "Hooks for %s are already defined"

        def initialize(method) = super(MESSAGE_TEMPLATE % method)
      end

      Hook = Data.define(:method_name, :before, :after) do
        Callback = Data.define(:target, :options)

        def initialize(method_name:, before: [], after: []) = super
        def callbacks = {before:, after:}

        def add_callback(type:, target:, options: {})
          new_callback = Callback[target:, options:]

          raise ArgumentError, "Callback already defined" if callbacks[type].map(&:hash).to_set === new_callback.hash

          callbacks[type] << new_callback
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module ClassMethods
        def hooks = @__hooks ||= {}

        def inherited(subclass)
          deep_dup_hooks(subclass)
        end

        # Defines before & after hooks for a method.
        #
        # @param method [Symbol] the name of the callbackable method.
        # @param name [Symbol] custom name of callbacks before_[name] & after_[name] methods.
        def define_hooks_for(method, name: method)
          raise(HookedMethodArgumentError, method) if hooks.key?(method)
          raise(MissingHookableMethod, method) unless method_defined?(method)

          override_hookable_method(method, name:)
          hooks[name] = Hook[method_name: name]
          define_callback_methods_for(name)
        end

        # Defines specific callback for a method.
        #
        # @param type [Symbol] the type of callback, `:before` or `:after`
        # @param method_name [Symbol] the name of the callbackable method.
        # @param target [Symbol] the name of the callback method.
        # @param options [Hash] the options for the callback.
        # @options options [Symbol] :if the name of the method to check before executing the callback.
        def set_callback(type, method_name, target, options = {})
          hooks[method_name].add_callback(type:, target:, options:)
        end

        private

        def deep_dup_hooks(subclass)
          subclass.instance_variable_set(:@__hooks, Marshal.load(Marshal.dump(hooks)))
        end

        def override_hookable_method(method, name:)
          define_method(method) do |*args|
            with_callbacks(name) { super(*args) }
          end
        end

        def define_callback_methods_for(method)
          TYPES.each do |type|
            define_singleton_method("#{type}_#{method}") do |target, options = {}|
              set_callback(type, method, target, options)
            end
          end
        end
      end

      module InstanceMethods
        def with_callbacks(method_name, &block)
          _run_callbacks(method_name, :before)
          result = yield
          _run_callbacks(method_name, :after)

          result
        end

        private

        def _run_callbacks(method, type)
          callbacks = self.class.hooks[method].callbacks[type]
          callbacks.each(&method(:_execute_callback))
        end

        def _execute_callback(callback)
          _validate_callback!(callback)
            .then { _process_callback_filters(callback.options) }
            .then { |filters_result| _execute_callback_method(callback.target) if filters_result }
        end

        def _validate_callback!(callback)
          raise(MissingCallbackContext, callback.target) unless respond_to?(callback.target, true)
        end

        def _process_callback_filters(options)
          return false if options[:if] && !send(options[:if])

          true
        end

        def _execute_callback_method(target)
          send(target)
        end
      end
    end
  end
end
