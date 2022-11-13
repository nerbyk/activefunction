# frozen_string_literal: true

module ActiveFunction::Functions
  module Params
    Error                 = Class.new(StandardError)
    ParameterMissingError = Class.new(Error) { def initialize(param) = super("param is missing or the value is empty: #{param}") }

    def params
      @_params ||= Parameters.new @request[:queryStringParameters]
    end

    class Parameters
      def initialize(params)
        @params = params
      end

      def [](key)
        attribute = @params[key]
        attribute.is_a?(Hash) ? Parameters.new(attribute) : attribute
      end

      def require(attribute)
        required_params = self[attribute]

        if required_params.present?
          required_params
        else
          raise ParameterMissingError, attribute
        end
      end

      def permit(*attributes)
        @params.select { |a| attributes.include? a.to_sym }
      end

      def present?
        @params.any?

        self
      end
    end
  end
end



