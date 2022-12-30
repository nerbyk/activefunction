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

    def self.handler(**options)
      options         = Hash[options]
      options[:event] = JSON.parse(options[:event], symbolize_names: true)

      new(**options).send(:process)
    end
  end
end
