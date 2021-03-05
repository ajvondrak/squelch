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

    def test_pairs_hit
      assert_equal Database.pairs(:postgres), Database.pairs(:postgres)
      refute_equal Database.pairs(:default), Database.pairs(:postgres)
    end

    def test_pairs_miss
      assert_equal Database.pairs(:default), Database.pairs(:redshift)
    end
  end
end
