require "./active_function/functions"
require "./active_function/logger"

require "ruby-next"
require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunction
  include Functions
end
