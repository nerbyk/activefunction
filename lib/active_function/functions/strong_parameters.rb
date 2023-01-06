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
          @permitted  = permitted
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
                pparams[k] = permit_nested_attribute(k, v)
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

          parameters.transform_values { convert_nested(_1) }
        end

        private

        def nested_attribute(attribute)
          case attribute
          in Hash[**] then Parameters.new(attribute)
          in Array[Hash[**], *] then attribute.map { Parameters.new(_1) }
          else attribute
          end
        end

        def permit_nested_attribute(key, value)
          case self[key]
          in Parameters then self[key].permit(*value)
          in Array[Parameters, *] then self[key].map { _1.permit(*value) }
          else self[key]
          end
        end

        def convert_nested(value)
          case value
          in Parameters then value.to_h
          in Array[Parameters, *] then value.map { _1.to_h }
          else value
          end
        end

        attr_reader :parameters
      end
    end
  end
end
