# frozen_string_literal: true

module ActiveFunction
  module Functions
    # Setups {before_action} and {after_action} callbacks around {ActiveFunction::SuperBase#process}
    # using {ActiveFunctionCore::Plugins::Hooks}. Also provides {define_hooks_for} and {set_callback_options} for
    # defining custom hooks & options.
    #
    # @example
    #   ActiveFunction.plugin :callbacks
    #
    #   class MessagingApp < ActiveFunction::Base
    #     set_callback_options retries: ->(times, context:) { context.retry if context.retries < times }
    #     define_hooks_for :retry
    #
    #     after_action :retry, if: :failed?, only: %i[send_message], retries: 3
    #     after_retry :increment_retries
    #
    #     def send_message
    #       @response.status = 200 if SomeApi.send(@request[:message_content]).success?
    #     end
    #
    #     def retry
    #       @response.committed = false
    #       process
    #     end
    #
    #     private def increment_retries = @response.body[:tries] += 1
    #     private def failed? = @response.status != 200
    #     private def retries = @response.body[:tries] ||= 0
    #   end
    #
    #   MessagingApp.process(:send_message, { sender_name: "Alice", message_content: "How are you?" })
    # defining custom hooks & options.
    module Callbacks
      ActiveFunction.register_plugin :callbacks, self

      # Setup callbacks around {ActiveFunction::Base#process} method using {ActiveFunctionCore::Plugins::Hooks}.
      # Also provides :only option for filtering callbacks by action name.
      def self.included(base)
        base.include ActiveFunctionCore::Plugins::Hooks
        base.define_hooks_for :process, name: :action
        base.set_callback_options only: ->(args, context:) { args.to_set === context.action_name }
      end

      # @!method before_action(target, options)
      #  @param [Symbol, String] target - method name to call
      #  @option options [Symbol, String] :if - method name to check before executing the callback.
      #  @option options [Symbol, String] :unless - method name to check before executing the callback.
      #  @option options [Array<Symbol, String>] :only - array of action names.
      #  @see ActiveFunctionCore::Plugins::Hooks::ClassMethods#set_callback
      # @!method after_action(target, options)
      #  @param [Symbol, String] target - method name to call
      #  @option options [Symbol, String] :if - method name to check before executing the callback.
      #  @option options [Symbol, String] :unless - method name to check before executing the callback.
      #  @option options [Array<Symbol, String>] :only - array of action names.
      #  @see ActiveFunctionCore::Plugins::Hooks::ClassMethods#set_callback

      # @!method set_callback(type, hook_name, target, options)
      #  @see ActiveFunctionCore::Plugins::Hooks::ClassMethods#set_callback

      # @!method define_hooks_for(method_name, name: method_name)
      #  @see ActiveFunctionCore::Plugins::Hooks::ClassMethods#define_hooks_for

      # @!method set_callback_options(options)
      #  @see ActiveFunctionCore::Plugins::Hooks::ClassMethods#set_callback_options
    end
  end
end
