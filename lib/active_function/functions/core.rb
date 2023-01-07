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
      RESPONSE = {statusCode: 200, body: {}, headers: {}}.freeze

      def self.included(base)
        base.extend(ClassMethods)
      end

      attr_reader :action_name, :request, :response

      def initialize(action_name, request)
        @request        = request
        @action_name    = action_name
        @performed      = false
        @response       = Hash[RESPONSE]
      end

      def process
        raise MissingRouteMethod, action_name unless respond_to?(action_name)

        public_send(action_name)

        raise NotRenderedError, action_name unless performed?

        @response.to_h
      end

      private def performed? = @performed

      module ClassMethods
        def process(action_name, request: {})
          new(action_name, request).process
        end
      end
    end
  end
end
