# frozen_string_literal: true

module ActiveFunction
  module Functions
    # The only required plugin for {ActiveFunction::Base} to work.
    # Provides a simple {Response} object to manage response details.
    #
    # @example
    #   response = Response.new.tap do |r|
    #     r.body = "Hello World!"
    #     r.headers = {"Content-Type" => "text/plain"}
    #     r.commit!
    #   end
    #
    #   response.performed? # => true
    #   response.to_h # => { statusCode: 200, headers: { "Content-Type" => "text/plain" }, body: "Hello World!" }
    module Response
      ActiveFunction.register_plugin :response, self

      class Response < Struct.new(:status, :headers, :body, :committed)
        # Initializes a new Response instance with default values.
        #
        # @param status [Integer] HTTP status code.
        # @param headers [Hash] HTTP headers.
        # @param body [Object] Response body.
        # @param committed [Boolean] Indicates whether the response has been committed (default is false).
        def initialize(status: 200, headers: {}, body: nil, committed: false) = super(status, headers, body, committed)

        # Converts the Response instance to a hash for JSON serialization.
        #
        # @return [Hash{statusCode: Integer, headers: Hash, body: Object}]
        def to_h
          {
            statusCode: status,
            headers:,
            body:
          }
        end

        # Marks the response as committed.
        def commit!
          self.committed = true
        end

        alias_method :committed?, :committed
      end
    end
  end
end
