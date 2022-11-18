module ActiveFunction
  module Functions
    module Core
      class << self
        def self.dispatch(action_name, request, response)
          new.dispatch(action_name, request, response)
        end
      end

      attr_reader :action_name, :request, :response

      def dispatch(env)
        (@action_name, @request, @response) = env

        process(@action_name)
      rescue StandardError => e
        ActiveFunction::Logger.error(e)
      ensure
        @response.to_h
      end

      protected

      def route
        raise NotImplementedError, "routing is not implemented under #{self.class.name} class"
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
