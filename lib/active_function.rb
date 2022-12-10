# frozen_string_literal: true

require "ruby-next"
require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunction # :nodoc:
  class Error < StandardError; end

  require "active_function/version"
  require "active_function/base"
  require "active_function/event_source"
end
