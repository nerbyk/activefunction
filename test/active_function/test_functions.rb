# frozen_string_literal: true

require "test_helper"

class ActiveFunction::Functions < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ActiveFunction::Functions::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
