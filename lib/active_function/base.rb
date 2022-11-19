# frozen_string_literal: true

module ActiveFunction
  class Base
    require "active_function/functions/core"
    require "active_function/functions/callbacks"
    require "active_function/functions/params"
    require "active_function/functions/implicit_rendering"
    require "active_function/functions/json_renderer"
    require "active_function/functions/rendering"

    include Functions::Rendering
    include Functions::JsonRenderer
    include Functions::ImplicitRendering
    include Functions::Params
    include Functions::Callbacks
    include Functions::Core
  end
end
