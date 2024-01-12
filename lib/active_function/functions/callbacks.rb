# frozen_string_literal: true

module ActiveFunction
  module Functions
    module Callbacks
      ActiveFunction.register_plugin :callbacks, self

      def self.included(base)
        base.include ActiveFunctionCore::Plugins::Hooks
        base.define_hooks_for :process, name: :action
        base.set_callback_options only: ->(args, context:) { args.to_set === context.action_name }
      end
    end
  end
end
