# frozen_string_literal: true

require "active_function_core"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunction
  class Error < StandardError; end

  require "active_function/version"
  require "active_function/base"
end
