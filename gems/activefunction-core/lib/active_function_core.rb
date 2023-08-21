# frozen_string_literal: true

require 'polyfill-data'
require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunctionCore
  class Error < StandardError; end

  require "plugins/hooks"

  require "active_function_core/version"
end
