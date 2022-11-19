# frozen_string_literal: true

module ActiveFunction
  module Functions
    module Rendering
      def render(*args)
        options = args.first || {}

        render_json(options)

        @performed = true
      end
    end
  end
end
