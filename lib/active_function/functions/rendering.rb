# frozen_string_literal: true

module ActiveFunction
  module Functions
    module Rendering
      def render(*args)
        options = args.first || {}

        rendered_body = render_to_body(options)

        self.response_body = rendered_body
      end
    end
  end 
end
