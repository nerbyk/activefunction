# frozen_string_literal: true

require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunctionCore
  Error = Class.new(StandardError)

  require "plugins/hooks"

  require "active_function_core/version"
end
