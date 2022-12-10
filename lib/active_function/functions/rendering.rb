# frozen_string_literal: true

module ActiveFunction
  class DoubleRenderError < Error
    MESSAGE_TEMPLATE = "render was called multiple times in %s action."

    attr_reader :message

    def initialize(action_name)
      @message = MESSAGE_TEMPLATE % action_name
    end
  end

  module Functions
    module Rendering
      DEFAULT_HEADER = {"Content-Type" => "application/json"}.freeze

      def render(status: 200, json: {}, head: {})
        raise DoubleRenderError, @route if @performed

        @response[:statusCode] = status
        @response[:headers]    = head.merge(Hash[DEFAULT_HEADER])
        @response[:body]       = JSON.generate(json)

        @performed = true
      end
    end
  end
end
