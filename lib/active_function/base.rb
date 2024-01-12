# frozen_string_literal: true

module ActiveFunction
  class SuperBase
    attr_reader :action_name, :request, :response

    def initialize(action_name, request, response)
      @action_name = action_name
      @request     = request
      @response    = response
    end

    def dispatch
      process(action_name)

      @response.commit! unless performed?

      @response.to_h
    end

    def process(action) = public_send(action)

    private def performed? = @response.committed?
  end

  class Base < SuperBase
    Error = Class.new(StandardError)

    # @param [String, Symbol] action_name - name of method to call
    # @param [Hash] request - request params, accessible through `#params` method
    # @param [Response] response - response object
    def self.process(action_name, request = {}, response = Response.new)
      raise ArgumentError, "Action method #{action_name} is not defined" unless method_defined?(action_name)

      new(action_name, request, response).dispatch
    end
  end
end
