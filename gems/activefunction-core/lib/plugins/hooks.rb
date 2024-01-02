# frozen_string_literal: true
require "forwardable"

module ActiveFunctionCore
  module Plugins
    module Hooks
      class MissingCallbackContext < Error
        MESSAGE_TEMPLATE = "Missing callback context: %s"

        attr_reader :message

        def initialize(context)
          @message = MESSAGE_TEMPLATE % context
        end
      end

      class MissingHookableMethod < Error
        MESSAGE_TEMPLATE = "Method %s is not defined"

        attr_reader :message

        def initialize(method_name)
          @message = MESSAGE_TEMPLATE % method_name
        end
      end

      TYPES = %i[before after].freeze
      # rubocop:disable Lint/ConstantDefinitionInBlock
      Hooks = Data.define(:hooks) do
        def initialize(hooks: {}) = super
        def deep_dup              = Marshal.load(Marshal.dump(self))
        def all                   = hooks
        def [](method_name)       = hooks[method_name]

        def add_hook(method_name)
          hooks[method_name] = Hook[method_name]
        end
      end

      Hook = Data.define(:method_name, :before, :after) do
        Callbacks = Data.define(:callbacks) do
          include Enumerable
          extend Forwardable

          Callback = Data.define(:target, :options)

          def_delegators :callbacks, :each

          def initialize(callbacks: []) = super

          def add(type:, target:, options:)
            callback = Callback[target:, options:]
            callbacks << callback unless callback_exists? callback
          end

          private def callback_exists?(new_callback)
            Set.new(callbacks.map(&:hash)) === new_callback.hash
          end
        end

        def initialize(method_name:, before: Callbacks.new, after: Callbacks.new)
          super
        end

        def callbacks
          {before:, after:}
        end

        def add_callback(type:, target:, options: {})
          raise ArgumentError, "Invalid callback type: #{type}" unless TYPES.include?(type)

          callbacks[type].add(type:, target:, options:)
        end
      end

      # rubocop:enable Lint/ConstantDefinitionInBlock
      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module InstanceMethods
        private

        def _hooks = self.class.hooks

        def with_callbacks(method_name, &block)
          run_callbacks_for(method_name, :before)
          result = yield
          run_callbacks_for(method_name, :after)

          result
        end

        def run_callbacks_for(method, type)
          _hooks[method].callbacks[type].each(&method(:_execute_callback))
        end

        def _execute_callback(callback)
          raise(MissingCallbackContext, callback) unless respond_to?(callback.target, true)

          send(callback.target) if _executable?(callback.options)
        end

        def _executable?(options)
          return false if options[:if] && !send(options[:if])

          true
        end
      end

      module ClassMethods
        # Defines before & after hooks for a method.
        #
        # @param method [Symbol] the name of the callbackable method.
        # @param name [Symbol] custom name of callbacks before_[name] & after_[name] methods.
        def define_hooks_for(method, name: method)
          override_hookable_method(method, name:)

          hooks.add_hook(name)

          define_callback_methods_for(name)
        end

        # Defines specific callback for a method.

        # @param type [Symbol] the type of callback, `:before` or `:after`
        # @param method_name [Symbol] the name of the callbackable method.
        # @param target [Symbol] the name of the callback method.
        # @param options [Hash] the options for the callback.
        # @options options [Symbol] :if the name of the method to check before executing the callback.
        def set_callback(type, method_name, target, options = {})
          hooks[method_name].add_callback(type:, target:, options:)
        end

        # @return [Hooks] the hooks for the class.
        def hooks
          @__hooks ||= Hooks.new
        end

        private

        def inherited(subclass)
          subclass.instance_variable_set(:@__hooks, @__hooks.deep_dup)
        end

        def override_hookable_method(method, name:)
          raise(MissingHookableMethod, method) unless method_defined?(method)

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
    end
  end
end
