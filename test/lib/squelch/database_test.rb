# frozen_string_literal: true

require "test_helper"

module Squelch
  class DatabaseTest < Minitest::Test
    def test_pattern_hit
      assert_equal Database.pattern(:mysql), Database.pattern(:mysql)
      refute_equal Database.pattern(:default), Database.pattern(:mysql)
    end

    def test_pattern_miss
      assert_equal Database.pattern(:default), Database.pattern(:aurora)
    end
  end
end
