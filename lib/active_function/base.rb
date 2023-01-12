# frozen_string_literal: true

module ActiveFunction
  class Base
    require "active_function/functions/core"
    require "active_function/functions/callbacks"
    require "active_function/functions/strong_parameters"
    require "active_function/functions/rendering"
    require "active_function/functions/response"

    include Functions::Core
    include Functions::Rendering
    include Functions::StrongParameters
    include Functions::Callbacks

    def self.process(action_name, request = {}, response = Functions::Response.new)
      new.dispatch(action_name, request, response)
    end
  end
end
