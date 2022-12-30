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

  class NotRenderedError < Error
    MESSAGE_TEMPLATE = "render was not called: %s"

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

      private def process
        raise MissingRouteMethod, @route unless respond_to?(@route)

        public_send @route

        raise NotRenderedError, @route unless @performed

        @response.to_h
      end
    end
  end
end
