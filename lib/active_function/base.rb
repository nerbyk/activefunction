# frozen_string_literal: true

module ActiveFunction
  class Base
    require "active_function/functions/core"
    require "active_function/functions/callbacks"
    require "active_function/functions/strong_parameters"
    require "active_function/functions/rendering"

    include Functions::Core
    include Functions::Rendering
    include Functions::StrongParameters
    include Functions::Callbacks
  end
end
