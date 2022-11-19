# frozen_string_literal: true

require "json"

module ActiveFunction
  module Functions
    module JsonRenderer
      def render_json(options)
        json = options[:json]
        status = options[:status]

        @response[:statusCode] = status unless status.nil?
        @response[:headers]["Content-Type"] = "application/json"

        @response[:body] = JSON.generate(json)
      end
    end
  end
end
