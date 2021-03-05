# frozen_string_literal: true

module Squelch
  # @private
  module Pairs
    SINGLE_QUOTED = "'"
    DOUBLE_QUOTED = '"'
    DOLLAR_QUOTED = /\$(?!\?)/.freeze
    BLOCK_COMMENT = Regexp.union("/*", "*/").freeze
  end
end
