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

    include \
      Function::Core,
      Function::Callbacks,
      Function::Params,
      Function::ImplicitRendering,
      Function::JsonRenderer,
      Function::Rendering,
      Function::Routing
  end
end
