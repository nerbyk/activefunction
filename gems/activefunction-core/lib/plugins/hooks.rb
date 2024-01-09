# frozen_string_literal: true

require "forwardable"

# TODO: remove with new ruby-next release
if RUBY_VERSION < "3.2"
  Data.define_singleton_method(:inherited) do |subclass|
    subclass.instance_variable_set(:@members, members)
  end
end

module ActiveFunctionCore
  module Plugins
    module Hooks
      class Hook < Data.define(:method_name, :callbacks)
        DEFAULT_CALLBACK_OPTIONS = {
          if: ->(v, context:) { context.send(v) if context.respond_to?(v, true) },
          unless: ->(v, context:) { !context.send(v) if context.respond_to?(v, true) }
        }.freeze
        SUPPORTED_CALLBACKS = %i[before after].freeze

        Callback = Data.define(:target, :options) do
          def run(context)
            context.instance_exec(target, options) do |target, options|
              raise(ArgumentError, "Callback target #{target} is not defined") unless respond_to?(target, true)

              method(target).call if options.all? { |opt| opt[context] }
            end
          end
        end

        def initialize(callbacks: SUPPORTED_CALLBACKS.dup, **)
          super(callbacks: callbacks.to_h { [_1, []] }, **)
        end

        def add_callback(type:, target:, options: {})
          callbacks[type] << Callback[target, options].tap do |callback|
            next unless callbacks[type].map(&:hash).to_set === callback.hash

            raise(ArgumentError, "Callback already defined")
          end
        end

        def run_callbacks(context, &block)
          callbacks[:before].each { |it| it.run(context) }

          yield_result = yield

          callbacks[:after].each { |it| it.run(context) }

          yield_result
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def hooks = @__hooks ||= {}
        def callback_options = @__callback_options ||= Hook::DEFAULT_CALLBACK_OPTIONS.dup

        def inherited(subclass)
          subclass.instance_variable_set(:@__hooks, Marshal.load(Marshal.dump(hooks)))
          subclass.instance_variable_set(:@__callback_options, callback_options.dup)
        end

        # Redefines method providing callbacks calls around it.
        # Defines `before_[name]` and `after_[name]` methods for setting callbacks.
        #
        # @param method [Symbol] the name of the callbackable method.
        # @param name [Symbol] alias for hooked method before_[name] & after_[name] methods.
        def define_hooks_for(method, name: method)
          raise(ArgumentError, "Hook for #{method} are already defined") if hooks.key?(method)
          raise(ArgumentError, "Method #{method} is not defined") unless method_defined?(method)

          hooks[name] = Hook.new(name)

          define_singleton_method(:"before_#{name}") do |target, options = {}|
            set_callback(:before, name, target, options)
          end

          define_singleton_method(:"after_#{name}") do |target, options = {}|
            set_callback(:after, name, target, options)
          end

          define_method(method) do |*args, &block|
            self.class.hooks[name].run_callbacks(self) do
              super(*args, &block)
            end
          end
        end

        # Sets a callback for an existing hook'ed method.
        #
        # @param type [Symbol] the type of callback, `:before` or `:after`
        # @param method_name [Symbol] the name of the callbackable method.
        # @param target [Symbol] the name of the callback method.
        # @param options [Hash] the options for the callback.
        # @options options [Symbol] :if the name of the method to check before executing the callback.
        def set_callback(type, method_name, target, options = {})
          raise(ArgumentError, "Hook for :#{method_name} is not defined") unless hooks.key?(method_name)
          raise(ArgumentError, "Options #{unknown} are not defined") if (unknown = (options.keys - callback_options.keys)) && unknown.any?

          hooks[method_name].add_callback(type:, target:, options: _normalized_options(options))
        end

        # Sets a custom callback option.
        #
        # @param name [Symbol] the name of the option.
        # @yield [*attrs, context:] the block to call.
        # @yieldparam attrs [*] the attributes passed to the option.
        # @yieldparam context [Object] the instance context (optional).
        # @yieldreturn [Boolean].
        def set_callback_options(name, &block)
          callback_options[name] = block
        end

        private def _normalized_options(options)
          options.map do |key, value|
            ->(instance) { callback_options[key].call(value, context: instance) }
          end
        end
      end
    end
  end
end
