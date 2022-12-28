# frozen_string_literal: true

require "json"

module ActiveFunction
  class MissingRouteMethod < Error
    MESSAGE_TEMPLATE = "Missing function route: %s"

    attr_reader :message

    def initialize(context)
      @message = MESSAGE_TEMPLATE % context
    end
  end

  module Functions
    module Core
      RESPONSE = {
        statusCode: 200,
        body:       {},
        headers:    {}
      }.freeze

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      attr_reader :event, :context

      def initialize(event:, context: nil)
        @event          = event
        @context        = context
        @route          = route
        @performed      = false
        @response       = Hash[RESPONSE]
      end

      def route
        raise NotImplementedError, "Please, define 'route: -> Symbol' method!"
      end

      private

      def process
        raise MissingRouteMethod unless respond_to?(@route)

        public_send @route

        render unless @performed

        @response.to_h
      end

      module ClassMethods # :nodoc:
        def handler(**options)
          options         = Hash[options]
          options[:event] = JSON.parse(options[:event], symbolize_names: true)

          new(**options).send(:process)
        end
      end
    end
  end
end
