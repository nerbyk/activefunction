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
      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def process(*)
        run_callbacks do
          super
        end
      end

      private

      def run_callbacks
        exec_callbacks(:before)

        yield if block_given?

        exec_callbacks(:after)
      end

      def exec_callbacks(type)
        self.class.callbacks[type].each do |callback_method, filters|
          raise MissingCallbackContext, callback_method unless respond_to?(callback_method, true)
          
          send(callback_method) if filters[:if][action_name]
        end
      end

      module ClassMethods # :nodoc:
        CALLBACKS = {before: {}, after: {}}.freeze

        def before_action(method_name, **options)
          set_callback(:before, method_name, filter(options))
        end

        def after_action(method_name, **options)
          set_callback(:after, method_name, filter(options))
        end

        def callbacks
          return @callbacks if instance_variable_defined?(:@callbacks)

          @callbacks = CALLBACKS
        end

        def filter(options)
          if only_list = options[:only]
            options[:if] = proc { |action| only_list.map(&:to_s).include?(action) }
          end

          options
        end

        def set_callback(type, method_name, filters)
          callbacks[type][method_name] = filters
        end

        private :filter, :set_callback
      end
    end
  end
end
