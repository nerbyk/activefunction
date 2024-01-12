# frozen_string_literal: true

require "active_function_core"
require "active_function/version"
require "active_function/base"

RubyNext::Language.setup_gem_load_path(transpile: true)

class ActiveFunction
  def self.inherited(subclass)
    subclass.instance_variable_set(:@_plugins, plugins.dup)
  end

  def self.plugins = @_plugins ||= {}

  def self.register_plugin(symbol, mod)
    plugins[symbol] = mod
  end

  def self.plugin(mod)
    if mod.is_a? Symbol
      require "active_function/functions/#{mod}"
      mod = plugins.fetch(mod)
    end

    self::Base.include(mod)
  end

  plugin :response
end
