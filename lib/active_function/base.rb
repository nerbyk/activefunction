# frozen_string_literal: true

module ActiveFunction
  class Base
    require "active_function/functions/core"
    require "active_function/functions/callbacks"
    require "active_function/functions/params"
    require "active_function/functions/implicit_rendering"
    require "active_function/functions/json_renderer"
    require "active_function/functions/rendering"
    require "active_function/functions/routing"

    include Function::Routing
    include Function::Rendering
    include Function::JsonRenderer
    include Function::ImplicitRendering
    include Function::Params
    include Function::Callbacks
    include Function::Core
  end
end
