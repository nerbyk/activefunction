# frozen_string_literal: true

require "ruby-next"
require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunctionCore
  class Error < StandardError; end

  require "active_function_core/version"
end
