# frozen_string_literal: true

module ActiveFunction
  # Abstract base class with request processing logic.
  class SuperBase
    attr_reader :action_name, :request, :response

    def initialize(action_name, request, response)
      @action_name = action_name
      @request     = request
      @response    = response
    end

    # Executes specified @action_name instance method and returns Hash'ed response object
    def dispatch
      process(action_name)

      @response.commit! unless performed?

      @response.to_h
    end

    def process(action) = public_send(action)

    private def performed? = @response.committed?
  end

  # The main base class for defining functions using the ActiveFunction framework.
  # Public methods of this class are considered as actions and be proceeded on {ActiveFunction::Base.process} call.
  #
  # @example
  #   class MyFunction < ActiveFunction::Base
  #      def index
  #         if user = User.find(@request.dig(:data, :user, :id))
  #             @response.body = user.to_h
  #         else
  #             @response.status = 404
  #         end
  #      end
  #   end
  class Base < SuperBase
    Error = Class.new(StandardError)

    # Processes specified action and returns Hash'ed {ActiveFunction::Functions::Response::Response} object.
    #
    # @example
    #   MyFunction.process :index, { data: { user: { id: 1 } } } # => { statusCode: 200, body: { id: 1, name: "Pupa" }, headers: {} }
    #
    # @param [String, Symbol] action_name - name of method to call
    # @param [Hash] request - request parameters.
    # @param [Response] response - Functions::Response response object.
    def self.process(action_name, request = {}, response = Response.new)
      raise ArgumentError, "Action method #{action_name} is not defined" unless method_defined?(action_name)

      new(action_name, request, response).dispatch
    end
  end
end
