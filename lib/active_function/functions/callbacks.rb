# frozen_string_literal: true

module ActiveFunction
  class MissingCallbackContext < Error # :no_doc:
    MESSAGE_TEMPLATE = "Missing callback context: %s"

    attr_reader :message

    def initialize(context)
      @message = MESSAGE_TEMPLATE % context
    end
  end

  module Functions
    module Callbacks # :nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      def process(*)
        _run_callbacks :before

        super

        _run_callbacks :after
      end

      private

      def _run_callbacks(type)
        self.class.callbacks[type].each do |callback_method, options|
          raise MissingCallbackContext, callback_method unless respond_to?(callback_method, true)

          send(callback_method) if _executable?(options)
        end
      end

      def _executable?(options)
        return false if options[:only] && !options[:only]&.include?(action_name)
        return false if options[:if] && !send(options[:if])
        true
      end

      module ClassMethods # :nodoc:
        [:before, :after].each do |callback|
          define_method "#{callback}_action" do |method, options = {}|
            set_callback(callback, method, options)
          end
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
