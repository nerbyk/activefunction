# frozen_string_literal: true

module Kopilka::Functions
  module Rendering
    def render(*args)
      options = args.first || {}

      _normalize_options(options)

      rendered_body = render_to_body(options)

      self.response_body = rendered_body
    end

    private

    def _normalize_options(options)
      options
    end
  end
end
