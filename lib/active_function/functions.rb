# frozen_string_literal: true

Dir["/functions/*.rb"].each { |file| require file }

module ActiveFunction
  module Functions
    Error = Class.new(StandardError)
  end
end
