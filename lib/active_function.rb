# frozen_string_literal: true

require "active_function_core"
require "active_function/version"
require "active_function/base"

RubyNext::Language.setup_gem_load_path(transpile: true)

module ActiveFunction
  REQUIRED_FUNCTIONS_PLUGINS = %i[callbacks strong_parameters rendering response].freeze

  REQUIRED_FUNCTIONS_PLUGINS.each do |plugin|
    require "active_function/functions/#{plugin}"
  end

  def self.plugin(mod)
    mod.include Functions::Callbacks
    mod.include Functions::StrongParameters
    mod.include Functions::Rendering
    mod.const_set(:Response, Class.new(Functions::Response))
  end

  plugin(ActiveFunction::Base)
end
