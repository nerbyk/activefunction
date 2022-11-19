module ActiveFunction
  class WrongFunctionsRouteFormat < Error
    MESSAGE_TEMPLATE = "Wrong functions route wormat: %s, expected: { action: Symbol, params: Hash }"

    attr_reader :message

    def initialize(context)
      @message = MESSAGE_TEMPLATE % context
    end
  end

  module Functions
    module Core
      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      attr_reader :action_name, :request, :response, :performed
      alias_method :performed?, :performed

      def dispatch(**options)
        rparams = route(**options)

        raise WrongFunctionsRouteFormat, self.class.name unless rparams in { action: Symbol, params: Hash, **nil }

        @action_name = rparams[:action]
        @request = rparams[:params]
        @response = {statusCode: nil, body: {}, headers: {}} # TODO: extract to separate module
        @performed = false

        process(@action_name)

        @response.to_h
      end

      def route(*)
        raise NotImplementedError, "Please, define `route(event:, context:)` method!"
      end

      private

      def process(action_name)
        public_send(action_name)

        render unless performed?
      end

      module ClassMethods # :nodoc:
        def handler(**options)
          new.dispatch(**options)
        end
      end
    end
  end
end
