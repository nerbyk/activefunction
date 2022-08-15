# frozen_string_literal: true

module Kopilka::Functions
  class Base < SuperBase
    include Function::Callbacks
    include Function::Params
    include Function::ImplicitRendering
    include Function::JsonRenderer
    include Function::Rendering
    include Function::Routing

    protected def route
      raise NotImplementedError, "routing is not implemented under #{self.class.name} class"
    end 
  end
end
