# frozen_string_literal: true

# Source: https://github.com/ruby/spec/blob/master/core/data/fixtures/classes.rb

module DataSpecs
  ruby_version_is "3.2" do
    Measure = Data.define(:amount, :unit)
  end
end
