# frozen_string_literal: true

require "forwardable"

class ActiveFunction
  module Functions
    module StrongParameters
      ActiveFunction.register_plugin :strong_parameters, self

      Error = Class.new(StandardError)

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

        extend Forwardable
        include Enumerable

        def_delegators :params, :each, :map

        def [](attribute)
          nested_attribute(params[attribute])
        end

        def require(attribute)
          if (value = self[attribute])
            value
          else
            raise ParameterMissingError, attribute
          end
        end

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

        # Redefines RubyNext::Core::Data instance methods
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

      def params
        @_params ||= Parameters.new(@request, false)
      end
    end
  end
end
