# frozen_string_literal: true

module ActiveFunction::Functions
  module Callbacks
    CALLBACK_FILTER_TYPES = %i[before after].freeze

    def self.included(base)
      base.extend(ClassMethods)
    end

    def run_callbacks
      _run_callbacks(:before)

      yield if block_given?

      _run_callbacks(:after)
    end

    def process(*)
      run_callbacks do
        super
      end
    end

    private 

    def _run_callbacks(type)
      self.class.__callbacks[type].each do |callback_method, filters|
        public_send(callback_method) if filters[:if][action_name]
      end
    end

    module ClassMethods
      self.__callbacks = {
        before: {},
        after: {}
      }

      def before_action(method_name, **options)
        normalized_options = normalize_options(options)
        set_callback(:before, method_name, normalized_options)
      end

      def after_action(method_name, **options)
        normalized_options = normalize_options(options)
        set_callback(:after, method_name, normalized_options)
      end

      private

      def normalize_options(options)
        if only_list = options[:only]
          options[:if] = proc { |action| only_list.map(&:to_s).include?(action) }
        end

        options
      end

      def set_callback(type, method_name, filters)
        return unless CALLBACK_FILTER_TYPES.include?(type)

        __callbacks[type][method_name] = filters
      end
    end
  end 
end
