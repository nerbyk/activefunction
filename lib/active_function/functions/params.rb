# frozen_string_literal: true

module ActiveFunction
  class ParameterMissingError < Error
    MESSAGE_TEMPLATE = "Missing callback context: %s"

    attr_reader :message

    def initialize(param)
      MESSAGE_TEMPLATE % param
    end
  end

  module Functions
    module Params
      def params
        return @params if instance_variable_defined?(:@params)

        # TODO: Support custom params path
        @params = Parameters.new @request[:queryStringParameters]
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

          raise ParameterMissingError, attribute unless required_params.present?

          required_params
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
end
