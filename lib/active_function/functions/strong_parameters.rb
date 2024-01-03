# frozen_string_literal: true

require "forwardable"

module ActiveFunction
  class ParameterMissingError < Error
    MESSAGE_TEMPLATE = "Missing parameter: %s"

    attr_reader :message

    def initialize(param)
      MESSAGE_TEMPLATE % param
    end
  end

  class UnpermittedParameterError < Error
    MESSAGE_TEMPLATE = "Unpermitted parameter: %s"

    attr_reader :message

    def initialize(param)
      MESSAGE_TEMPLATE % param
    end
  end

  module Functions
    module StrongParameters
      def params
        @_params ||= Parameters.new(@request)
      end

      class Parameters
        extend Forwardable
        def_delegators :@parameters, :each, :map
        include Enumerable

        def initialize(parameters, permitted: false)
          @parameters = parameters
          @permitted = permitted
        end

        def [](attribute)
          nested_attribute(parameters[attribute])
        end

        def require(attribute)
          value = self[attribute]

          raise ParameterMissingError, attribute if value.nil?

          value
        end

        def permit(*attributes)
          pparams = {}

          attributes.each do |attribute|
            if attribute.is_a? Hash
              attribute.each do |k, v|
                pparams[k] = process_nested(self[k], :permit, v)
              end
            else
              next unless parameters.key?(attribute)

              pparams[attribute] = self[attribute]
            end
          end

          Parameters.new(pparams, permitted: true)
        end

        def to_h
          raise UnpermittedParameterError, parameters.keys unless @permitted

          parameters.transform_values { process_nested(_1, :to_h) }
        end

        private

        def nested_attribute(attribute)
          if attribute.is_a? Hash
            Parameters.new(attribute)
          elsif attribute.is_a?(Array) && attribute[0].is_a?(Hash)
            attribute.map { Parameters.new(_1) }
          else
            attribute
          end
        end

        def process_nested(attribute, method, options = [])
          if attribute.is_a? Parameters
            attribute.send(method, *options)
          elsif attribute.is_a?(Array) && attribute[0].is_a?(Parameters)
            attribute.map { _1.send(method, *options) }
          else
            attribute
          end
        end

        attr_reader :parameters
      end
    end
  end
end
