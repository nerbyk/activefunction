# frozen_string_literal: true

require "forwardable"

module ActiveFunctionCore
  module Plugins
    module Hooks
      class MissingHookableMethod < Error
        MESSAGE_TEMPLATE = "Method %s is not defined"

        def initialize(method_name) = super(MESSAGE_TEMPLATE % method_name)
      end

      class HookedMethodArgumentError < Error
        MESSAGE_TEMPLATE = "Hooks for %s are already defined"

        def initialize(method) = super(MESSAGE_TEMPLATE % method)
      end

      Hook = Data.define(:method_name, :before, :after) do
        Callback = Data.define(:target, :options) # rubocop:disable Lint/ConstantDefinitionInBlock

        def initialize(method_name:, before: [], after: []) = super
        def callbacks = {before:, after:}

        def add_callback(type:, target:, options: {})
          new_callback = Callback[target:, options:]

          raise ArgumentError, "Callback already defined" if callbacks[type].map(&:hash).to_set === new_callback.hash

          callbacks[type] << new_callback
        end
      end

      CallbackRunner = Data.define(:callbacks, :instance) do
        class MissingCallbackContext < Error # rubocop:disable Lint/ConstantDefinitionInBlock
          MESSAGE_TEMPLATE = "Missing callback context: %s"

          def initialize(context) = super(MESSAGE_TEMPLATE % context)
        end

        def execute_callbacks(type)
          callbacks[type].each(&method(:execute_callback))
        end

        private

        def execute_callback(callback)
          validate_callback!(callback)
            .then { process_callback_filters(callback.options) }
            .then { |filters_result| execute_callback_method(callback.target) if filters_result }
        end

        def validate_callback!(callback)
          raise(MissingCallbackContext, callback.target) unless instance.respond_to?(callback.target, true)
        end

        def process_callback_filters(options)
          return false if options[:if] && !instance.send(options[:if])

          true
        end

        def execute_callback_method(target)
          instance.send(target)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module ClassMethods
        def hooks = @__hooks ||= {}

        def inherited(subclass)
          subclass.instance_variable_set(:@__hooks, Marshal.load(Marshal.dump(hooks)))
        end

        # Redefines method providing callbacks calls around it.

        #
        # @param method [Symbol] the name of the callbackable method.
        # @param name [Symbol] custom name of callbacks before_[name] & after_[name] methods.
        def define_hooks_for(method, name: method)
          raise(HookedMethodArgumentError, method) if hooks.key?(method)
          raise(MissingHookableMethod, method) unless method_defined?(method)

          create_hook(name)

          add_callback_calls_to(method, name:)

          define_callback_methods_for(:before, name)
          define_callback_methods_for(:after, name)
        end

        # Sets a callback for an existing hook'ed method.
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

        def create_hook(name)
          hooks[name] = Hook[method_name: name]
        end

        def add_callback_calls_to(method, name:)
          define_method(method) do |*args|
            hook = self.class.hooks[name]
            with_callbacks(hook.callbacks) { super(*args) }
          end
        end

        def define_callback_methods_for(type, method)
          define_singleton_method("#{type}_#{method}") do |target, options = {}|
            set_callback(type, method, target, options)
          end
        end
      end

      module InstanceMethods
        # Executes callbacks around the block.
        #
        # @param callbacks [Hash{Symbol => Array<Hook::Callback>}] the callbacks to execute, with keys ':before' and ':after'.
        # @param block [Proc] the block to execute.
        def with_callbacks(callbacks, &block)
          callbacks_runner = CallbackRunner[callbacks:, instance: self]

          callbacks_runner.execute_callbacks(:before)
          result = yield
          callbacks_runner.execute_callbacks(:after)

          result
        end
      end
    end
  end
end
