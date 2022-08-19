# frozen_string_literal: true

module Kopilka::Functions
  class SuperBase
    include KopilkaFunction::Rendering

    def self.dispatch(action_name, request, response)
      new.dispatch(action_name, request, response)
    end

    attr_reader :action_name, :request, :response

    def dispatch(env)
      (@action_name,  @request, @response) = env

      process(@action_name)

    rescue => err
      Kopilka::Logger.error(err)
    ensure
      @response.to_h
    end

    private

    def process(action_name) = public_send(action_name)

    def response_body=(body)
      @response.body = body

      @performed = true
    end
  end
end
