# frozen_string_literal: true

require "json"

module ActiveFunction
  module Functions
    module Rendering
      ActiveFunction.register_plugin :rendering, self

      Error = Class.new(StandardError)

      class DoubleRenderError < Error
        MESSAGE_TEMPLATE = "#render was called multiple times in action: %s"

        attr_reader :message

        def initialize(context)
          @message = MESSAGE_TEMPLATE % context
        end
      end

      DEFAULT_HEADER = {"Content-Type" => "application/json"}.freeze

      def render(status: 200, json: {}, head: {})
        raise DoubleRenderError, @action_name if performed?

        @response.status     = status
        @response.headers    = head.merge(Hash[DEFAULT_HEADER])
        @response.body       = JSON.generate(json)

        @response.commit!
      end
    end
  end
end
