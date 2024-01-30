# frozen_string_literal: true

require "ruby-next/language/setup"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunctionCore
  Error = Class.new(StandardError)

  require "logger"
  require "active_function_core/version"
  require "active_function_core/plugins/hooks"
  require "active_function_core/plugins/types"

  def logger
    @logger ||= Logger.new($stdout).tap do |log|
      log.progname = name
    end
  end

  module_function :logger
end
