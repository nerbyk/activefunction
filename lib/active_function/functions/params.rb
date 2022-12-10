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
        @params ||= Parameters.new(@event)
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

          raise ParameterMissingError, attribute if required_params.nil?

          required_params
        end

        def permit(*attributes)
          @params.select { |a| attributes.include? a.to_sym }
        end

        def present?
          @params.any?
        end
      end
    end
  end
end
