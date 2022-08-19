# frozen_string_literal: true

require "ruby-next"

require "ruby-next/language/setup"
RubyNext::Language.setup_gem_load_path(transpile: true)

# require manually all files from functions folder  
require_relative "functions/callbacks"
require_relative "functions/implicit_rendering"
require_relative "functions/json_rederer"
require_relative "functions/params"
require_relative "functions/rendering"
require_relative "functions/super_base"
require_relative "functions/version"
require_relative "functions/logger"

module Kopilka
  module Functions
    Error = Class.new(StandardError)
  end
end
