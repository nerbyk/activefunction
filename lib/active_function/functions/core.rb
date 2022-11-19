module ActiveFunction
  module Functions
    module Core
      EMPTY_HASH = {}.freeze
      
      def self.handler
        new.dispatch(super, response = EMPTY_HASH)
      end 
      
      attr_reader :action_name, :request, :response

      def dispatch(env)
        [@action_name, @request, @response] => env

        process(@action_name)
      rescue => e
        ActiveFunction::Logger.error(e)
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
end
