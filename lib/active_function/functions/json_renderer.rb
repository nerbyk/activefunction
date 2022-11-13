# frozen_string_literal: true

require 'json'

module ActiveFunction::Functions
  module JsonRenderer
    def render_to_body(options)
      json = options[:json]
      status = options[:status]

      @response.statusCode = status unless status.nil?
      @response.headers['Content-Type'] = 'application/json'

      self.response_body = JSON.generate(json)
    end
  end
end 
