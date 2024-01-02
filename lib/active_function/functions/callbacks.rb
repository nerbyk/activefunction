# frozen_string_literal: true

module ActiveFunction
  module Functions
    module Callbacks
      def self.included(base)
        base.include(ActiveFunctionCore::Plugins::Hooks)
        base.define_hooks_for :process, name: :action
      end
    end
  end
end
