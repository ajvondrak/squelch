# frozen_string_literal: true

require "test_helper"

class SquelchTest < Minitest::Test
  def test_version
    refute_nil Squelch::VERSION
  end
end
