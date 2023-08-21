# frozen_string_literal: true

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

      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module InstanceMethods
        private

        def with_callbacks(method_name, &block)
          callbacks = _callbacks(method_name)

          _run_callbacks(callbacks.before)

          result = yield

          _run_callbacks(callbacks.after)

          result
        end

        def _callbacks(method_name)
          self.class.hooks[method_name].callbacks
        end

        def _run_callbacks(callbacks)
          callbacks.each do |callback|
            raise(MissingCallbackContext, callback) unless respond_to?(callback.target, true)

            send(callback.target) if _executable?(callback.options)
          end
        end

        def _executable?(options)
          return false if options[:if] && !send(options[:if])

          true
        end
      end

      module ClassMethods
        TYPES = %i[before after].freeze
        # rubocop:disable Lint/ConstantDefinitionInBlock
        Hooks = Data.define(:hooks) do
          def initialize(hooks: {}) ;  super; end
          def deep_dup ;  Marshal.load(Marshal.dump(self)); end
          def all ;  hooks; end
          def [](method_name) ;  hooks[method_name]; end

          def add_hook(method_name)
            hooks[method_name] = Hook[method_name]
          end
        end

        Hook = Data.define(:method_name, :callbacks) do
          Callbacks = Data.define(:before, :after) do
            def initialize(before: [], after: []) ;  super; end
            def [](type) ;  public_send(type); end
          end
          Callback = Data.define(:target, :options)

          def initialize(method_name:, callbacks: Callbacks.new) ;  super; end
          def hashes(type) ;  Set.new callbacks[type].map(&:hash); end

          def add_callback(type:, target:, options: {})
            new_callbacks = Callback[target, options]
            callbacks[type] << new_callbacks unless hashes(type) === new_callbacks.hash
          end
        end
        # rubocop:enable Lint/ConstantDefinitionInBlock

        def define_hooks_for(*method_names)
          method_names.each do |method_name|
            override_hookable_method(method_name)

            hooks.add_hook(method_name)

            define_callback_methods_for(method_name)
          end
        end

        def set_callback(type, method_name, target, options = {})
          hooks[method_name].add_callback(type: type, target: target, options: options)
        end

        def hooks
          @__hooks ||= Hooks.new
        end

        private

        def inherited(subclass)
          subclass.instance_variable_set(:@__hooks, @__hooks.deep_dup)
        end

        def override_hookable_method(method_name)
          raise(MissingHookableMethod, method_name) unless method_defined?(method_name)

          define_method(method_name) do |*args|
            with_callbacks(method_name) { super(*args) }
          end
        end

        def define_callback_methods_for(method_name)
          TYPES.each do |type|
            define_singleton_method("#{type}_#{method_name}") do |target, options = {}|
              set_callback(type, method_name, target, options)
            end
          end
        end
      end
    end
  end
end
