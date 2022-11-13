# frozen_string_literal: true

module ActiveFunction::Functions
  class Base < SuperBase
    include \
      Function::Callbacks,
      Function::Params,
      Function::ImplicitRendering,
      Function::JsonRenderer,
      Function::Rendering,
      Function::Routing

    protected def route
      raise NotImplementedError, "routing is not implemented under #{self.class.name} class"
    end 
  end
end
