# frozen_string_literal: true

require "forwardable"

module ActiveFunction
  module Functions
    # Allows manipulations with {ActiveFunction::SuperBase#request} via {params} instance method and {Parameters} object.
    #
    # @example
    #   require "active_function"
    #
    #   ActiveFunction.config do
    #     plugin :strong_parameters
    #   end
    #
    #   class PostsFunction < ActiveFunction::Base
    #     def index
    #       @response.body = permitted_params
    #     end
    #
    #     def permitted_params
    #       params.require(:data).permit(:id, :name).to_h
    #     end
    #   end
    #
    #   PostsFunction.process(:index, data: { id: 1, name: "Pupa" })
    module StrongParameters
      ActiveFunction.register_plugin :strong_parameters, self

      Error = Class.new(StandardError)
      # The Parameters class encapsulates the parameter handling logic.
      class Parameters < Data.define(:params, :permitted)
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

        protected :params

        # Allows access to parameters by key.
        #
        # @param attribute [Symbol] The key of the parameter.
        # @return [Parameters, Object] The value of the parameter.
        def [](attribute)
          nested_attribute(params[attribute])
        end

        # Requires the presence of a specific parameter.
        #
        # @param attribute [Symbol] The key of the required parameter.
        # @return [Parameters, Object] The value of the required parameter.
        # @raise [ParameterMissingError] if the required parameter is missing.
        def require(attribute)
          if (value = self[attribute])
            value
          else
            raise ParameterMissingError, attribute
          end
        end

        # Specifies the allowed parameters.
        #
        # @param attributes [Array<Symbol, Hash<Symbol, Array<Symbol>>>] The attributes to permit.
        # @return [Parameters] A new instance with permitted parameters.
        def permit(*attributes)
          pparams = {}

          attributes.each do |attribute|
            if attribute.is_a? Hash
              attribute.each do |k, v|
                pparams[k] = process_nested(self[k], :permit, v)
              end
            else
              next unless params.key?(attribute)

              pparams[attribute] = self[attribute]
            end
          end

          with(params: pparams, permitted: true)
        end

        # Converts parameters to a hash.
        #
        # @return [Hash] The hash representation of the parameters.
        # @raise [UnpermittedParameterError] if any parameters are unpermitted.
        def to_h
          raise UnpermittedParameterError, params.keys unless permitted

          params.transform_values { process_nested(_1, :to_h) }
        end

        def hash
          @attributes.to_h.hash
        end

        def with(params:, permitted: false)
          self.class.new(params, permitted)
        end

        private

        def nested_attribute(attribute)
          if attribute.is_a? Hash
            with(params: attribute)
          elsif attribute.is_a?(Array) && attribute[0].is_a?(Hash)
            attribute.map { |it| with(params: it) }
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
      end

      # Return params object with {ActiveFunction::SuperBase#request}.
      #
      # @return [Parameters] instance of {Parameters} class.
      def params
        @_params ||= Parameters.new(@request, false)
      end
    end
  end
end
