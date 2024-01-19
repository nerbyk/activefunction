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
    # Provides ActiveSupport::Callbacks like DSL for defining before and after callbacks around methods
    # @see ClassMethods DSL methods.
    # @example Hooks with default callback options
    #   class YourClass
    #     include ActiveFunctionCore::Plugins::Hooks
    #
    #     define_hooks_for :your_method
    #
    #     before_your_method :do_something_before, if: :condition_met?
    #     after_your_method :do_something_after, unless: :condition_met?
    #
    #     def your_method
    #       # Method implementation here...
    #     end
    #
    #     private
    #
    #     def condition_met?
    #       # Condition logic here...
    #     end
    #
    #     def do_something_before
    #       # Callback logic to execute before your_method
    #     end
    #
    #     def do_something_after
    #       # Callback logic to execute after your_method
    #     end
    #   end
    # @example Hooks with custom callback options
    #   class YourClass
    #     include ActiveFunction::Core::Plugins::Hooks
    #
    #     set_callback_options only: ->(only_methods, context:) { only_methods.include?(context.action) }
    #
    #     define_hooks_for :your_method
    #
    #     before_your_method :do_something_before, only: %[foo bar]
    #
    #     def action = "foo"
    #   end
    module Hooks
      # Represents a hook with callbacks for a specific method.
      class Hook < Data.define(:method_name, :callbacks)
        DEFAULT_CALLBACK_OPTIONS = {
          if:     ->(v, context:) { context.send(v) if context.respond_to?(v, true) },
          unless: ->(v, context:) { !context.send(v) if context.respond_to?(v, true) }
        }.freeze
        SUPPORTED_CALLBACKS      = %i[before after].freeze
        # Represents a callback with options.
        Callback                 = Data.define(:options, :target) do
          # Runs the callback within the specified contex.
          #
          # @param context [Object] instance of class with callbacks.
          def run(context)
            raise ArgumentError, "Callback target #{target} is not defined" unless context.respond_to?(target, true)
            raise ArgumentError, ":callback_options is not defined in #{context.class}" unless context.class.respond_to?(:callback_options)

            context.instance_exec(target, normalized_options(options, context)) do |target, options|
              method(target).call if options.all?(&:call)
            end
          end

          private def normalized_options(options, context)
            options.map do |option|
              name, arg = option
              -> { context.class.callback_options[name].call(arg, context:) }
            end
          end
        end

        def initialize(callbacks: SUPPORTED_CALLBACKS.dup, **)
          super(callbacks: callbacks.to_h { [_1, []] }, **)
        end

        # Adds a callback to the hook.
        #
        # @param type [Symbol] the type of callback, `:before` or `:after`
        # @param target [Symbol] the name of the callback method.
        # @param options [Hash] the options for the callback.
        # @options options [Symbol] :if the name of the method to check before executing the callback.
        # @options options [Symbol] :unless the name of the method to check before executing the callback.
        # @raise [ArgumentError] if callback already defined.
        def add_callback(type:, target:, options: {})
          callbacks[type] << Callback[options, target].tap do |callback|
            next unless callbacks[type].map(&:hash).to_set === callback.hash

            raise(ArgumentError, "Callback already defined")
          end
        end

        # Runs all callbacks for the hook.
        #
        # @param context [Object] instance of class with defined hook.
        # @yield [*args] block of code around which callbacks will be executed.
        # @return the result of the block.
        def run_callbacks(context, &block)
          callbacks[:before].each { |it| it.run(context) }

          yield_result = yield

          callbacks[:after].each { |it| it.run(context) }

          yield_result
        end
      end

      # DSL method for {ActiveFunctionCore::Plugins::Hooks}
      module ClassMethods
        # Returns all setuped hooks for the class.
        def hooks            = @__hooks ||= {}

        # Returns all setuped custom callback options for the class.
        def callback_options = @__callback_options ||= Hook::DEFAULT_CALLBACK_OPTIONS.dup

        # Inherited callback to ensure that callbacks are inherited from the base class.
        def inherited(subclass)
          subclass.instance_variable_set(:@__hooks, Marshal.load(Marshal.dump(hooks)))
          subclass.instance_variable_set(:@__callback_options, callback_options.dup)
        end

        # Setups hooks for provided method.
        # Redefines method providing callbacks calls around it.
        # Defines *before_[name]* and *after_[name]* methods for setting callbacks.
        #
        # @example
        #   define_hooks_for :process, name: :action
        #   before_action :set_first
        #   after_action :set_last, if: :ok?
        #
        # @param method [Symbol] the name of the callbackable method.
        # @param name [Symbol] alias for hooked method before_[name] & after_[name] methods.
        # @raise [ArgumentError] if hook for method already defined.
        # @raise [ArgumentError] if method is not defined.
        def define_hooks_for(method, name: method)
          raise(ArgumentError, "Hook for #{method} are already defined") if hooks.key?(method)

          hooks[name] = Hook.new(name)

          define_singleton_method(:"before_#{name}") do |target, options = {}|
            set_callback(:before, name, target, options)
          end

          define_singleton_method(:"after_#{name}") do |target, options = {}|
            set_callback(:after, name, target, options)
          end

          redefiner = Module.new do
            define_method(method) do |*args, &block|
              raise(ArgumentError, "Hook Method #{method} is not defined") unless defined?(super)

              self.class.hooks[name].run_callbacks(self) do
                super(*args, &block)
              end
            end
          end

          prepend redefiner
        end

        # Sets a callback for an existing hook'ed method.
        #
        # @example
        #   define_hooks_for :action
        #   set_callback :before, :action, :set_first
        #
        # @param type [Symbol] the type of callback, `:before` or `:after`
        # @param method_name [Symbol] the name of the callbackable method.
        # @param target [Symbol] the name of the callback method.
        # @param options [Hash] the options for the callback.
        # @option options [Symbol] :if the name of the booled method to call before executing the callback.
        # @option options [Symbol] :unless the name of the booled method to call before executing the callback.
        # @raise [ArgumentError] if hook for provided method is not setuped via ::define_hooks_for.
        # @raise [ArgumentError] if unsupported @options was passed.
        def set_callback(type, method_name, target, options = {})
          raise(ArgumentError, "Hook for :#{method_name} is not defined") unless hooks.key?(method_name)
          raise(ArgumentError, "Hook Callback accepts only #{callback_options.keys} options") if (options.keys - callback_options.keys).any?

          hooks[method_name].add_callback(type:, target:, options:)
        end

        # Sets a custom callback option.
        #
        # @example
        #   set_callback_option only: ->(args, context:) { args.to_set === context.current_action }
        #   define_hooks_for :action
        #   before_action :set_first, only: :index
        #
        # @param option [Hash{Symbol => Proc}] The custom callback option as a single-value hash.
        #   - :name [Symbol] The name of the option.
        #   - :block [Proc] The block to call.
        # @yield [*attrs, context:] the block to call.
        # @yieldparam attrs [*] the attributes passed to the option.
        # @yieldparam context [Object] the instance context (optional).
        # @yieldreturn [Boolean].
        def set_callback_options(option)
          name, block            = option.first
          callback_options[name] = block
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
