# frozen_string_literal: true

require "active_function_core"
require "active_function/version"
require "active_function/base"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunction
  class << self
    # Configure ActiveFunction through DSL method calls.
    # Setups {ActiveFunction::Base} with provided internal and custom plugins.
    # Also freezes plugins and {ActiveFunction::Base}.
    #
    # @example
    #  ActiveFunction.config do
    #    plugin :callbacks
    #  end
    #
    # @param block [Proc] class_eval'ed block in ActiveFunction module.
    # @return [void]
    def config(&block)
      class_eval(&block)
      @_plugins.freeze
      self::Base.freeze
    end

    # List of registered internal plugins.
    def plugins = @_plugins ||= {}

    # Register internal Symbol'ed plugin.
    #
    # @param [Symbol] symbol name of internal plugin,
    #   should match file name in ./lib/active_function/functions/*.rb
    # @param [Module] mod module to register.
    def register_plugin(symbol, mod)
      plugins[symbol] = mod
    end

    # Add plugin to ActiveFunction::Base.
    #
    # @example
    #  ActiveFunction.plugin :callbacks
    #  ActiveFunction.plugin CustomPlugin
    #
    # @param [Symbol, Module] mod
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
