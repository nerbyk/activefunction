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
      TYPES = [
        BEFORE = :before,
        AFTER  = :after
      ].freeze

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      private

      def process(*)
        run_callbacks { super }
      end

      def run_callbacks(&block)
        exec BEFORE

        yield

        exec AFTER
      end

      def exec(type)
        self.class.callbacks[type].each do |callback_method, options|
          raise MissingCallbackContext, callback_method unless respond_to?(callback_method, true)

          send(callback_method) if executable?(options)
        end
      end

      def executable?(options)
        return false unless options[:only]&.include?(@route)
        return false unless options[:if] && send(options[:if])
        true
      end

      module ClassMethods # :nodoc:
        DEFAULT_CALLBACK = Hash[TYPES.product([{}]).to_h].freeze

        TYPES.each do |callback|
          define_method(:"#{callback}_action") do |method, options = {}|
            callbacks[callback][method] = options
          end
        end

        def callbacks
          return @_callbacks if instance_variable_defined?(:@callbacks)

          @_callbacks = Hash[DEFAULT_CALLBACK]
        end
      end
    end
  end
end
