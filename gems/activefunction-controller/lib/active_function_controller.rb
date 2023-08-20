# frozen_string_literal: true

require_relative "active_function_controller/version"

module ActiveFunction
  module Controller
    class Error < StandardError; end

    class Base
      require_relative "active_function_controller/core"
      require_relative "active_function_controller/callbacks"
      require_relative "active_function_controller/strong_parameters"
      require_relative "active_function_controller/rendering"
      require_relative "active_function_controller/response"

      include Core
      include Callbacks
      include Rendering
      include StrongParameters

      def self.process(action_name, request = {}, response = Response.new)
        new.dispatch(action_name, request, response)
      end
    end
  end
end
