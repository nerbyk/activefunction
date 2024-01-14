# frozen_string_literal: true

require "json"

module ActiveFunction
  module Functions
    # Allows manipulations with {ActiveFunction::SuperBase#response} via {render} instance method.
    #
    # @example
    #   require "active_function"
    #
    #   ActiveFunction.config do
    #     plugin :rendering
    #   end
    #
    #   class PostsFunction < ActiveFunction::Base
    #     def index
    #       render json: {id: 1, name: "Pupa"}, status: 200, head: {"Some-Header" => "Some-Value"}
    #     end
    #   end
    #
    #   PostFunction.process(:index) # => { :statusCode=>200, :headers=> {"Content-Type"=>"application/json", "Some-Header" => "Some-Value"}, :body=>"{\"id\":1,\"name\":\"Pupa\"}" }
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

      # Render JSON response.
      #
      # @param status [Integer] HTTP status code (default is 200).
      # @param json [Hash] JSON data to be rendered (default is an empty hash).
      # @param head [Hash] Additional headers to be included in the response (default is an empty hash).
      #
      # @raise [DoubleRenderError] Raised if #render is called multiple times in the same action.
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
