# frozen_string_literal: true

module ActiveFunction
  class MissingCallbackContext < Error
    MESSAGE_TEMPLATE = "Missing callback context: %s"

    attr_reader :message

    def initialize(context)
      @message = MESSAGE_TEMPLATE % context
    end
  end

  module Functions
    module Callbacks
      def self.included(base)
        base.extend(ClassMethods)
      end

      private

      def process(*)
        _run_callbacks :before

        super

        _run_callbacks :after
      end

      def _run_callbacks(type)
        self.class.callbacks[type].each do |callback_method, options|
          raise MissingCallbackContext, callback_method unless respond_to?(callback_method, true)

          send(callback_method) if _executable?(options)
        end
      end

      def _executable?(options)
        return false if options[:only] && !options[:only].include?(@action_name)
        return false if options[:if] && !send(options[:if])
        true
      end

      module ClassMethods
        def inherited(subclass)
          subclass.instance_variable_set(:@__callbacks, @__callbacks)
        end

        def before_action(method, options = {})
          set_callback :before, method, options
        end

        def after_action(method, options = {})
          set_callback :after, method, options
        end

        def set_callback(type, method, options = {})
          callbacks[type][method] = options
        end

        def callbacks
          @__callbacks ||= {before: {}, after: {}}

          @__callbacks
        end
      end
    end
  end
end
