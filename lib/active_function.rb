# frozen_string_literal: true

require "active_function_core"
require "active_function/version"
require "active_function/base"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunction
  class << self
    # Configure ActiveFunction.
    #
    # @param block [Proc]
    # @return [void]
    def config(&block)
      class_eval(&block)
      @_plugins.freeze
      self::Base.freeze
    end

    def plugins = @_plugins ||= {}

    # Register plugin.
    #
    # @param symbol [Symbol]
    # @param mod [Module]
    def register_plugin(symbol, mod)
      plugins[symbol] = mod
    end

    # Monkey patch ActiveFunction::Base with provided plugin.
    #
    # @param mod [Symbol, Module]
    # @return [void]
    def plugin(mod)
      if mod.is_a? Symbol
        begin
          require "active_function/functions/#{mod}"
          mod = plugins.fetch(mod)
        rescue LoadError
          raise ArgumentError, "Unknown plugin #{mod}"
        end
      end

      self::Base.include(mod)
    end
  end

  plugin :response
end
