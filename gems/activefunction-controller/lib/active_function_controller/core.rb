# frozen_string_literal: true

module ActiveFunction::Controller
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

  module Core
    attr_reader :action_name, :request, :response

    def dispatch(action_name, request, response)
      @action_name = action_name
      @request     = request
      @response    = response

      raise MissingRouteMethod, @action_name unless respond_to?(action_name)

      process(@action_name)

      raise NotRenderedError, @action_name unless performed?

      @response.to_h
    end

    private

    def process(action) = public_send(action)

    def performed? = @response.committed?
  end
end
