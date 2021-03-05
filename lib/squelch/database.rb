# frozen_string_literal: true

module Squelch
  # @private
  module Database
    PATTERNS = {
      mysql: Regexp.union(
        Patterns::SINGLE_QUOTED,
        Patterns::DOUBLE_QUOTED,
        Patterns::NUMBER,
        Patterns::BOOLEAN,
        Patterns::HEXADECIMAL,
        Patterns::LINE_COMMENT,
        Patterns::BLOCK_COMMENT,
      ).freeze,
      postgres: Regexp.union(
        Patterns::SINGLE_QUOTED,
        Patterns::DOLLAR_QUOTED,
        Patterns::UUID,
        Patterns::NUMBER,
        Patterns::BOOLEAN,
        Patterns::LINE_COMMENT,
        Patterns::BLOCK_COMMENT,
      ).freeze,
      sqlite: Regexp.union(
        Patterns::SINGLE_QUOTED,
        Patterns::NUMBER,
        Patterns::BOOLEAN,
        Patterns::HEXADECIMAL,
        Patterns::LINE_COMMENT,
        Patterns::BLOCK_COMMENT,
      ).freeze,
      oracle: Regexp.union(
        Patterns::SINGLE_QUOTED,
        Patterns::ORACLE_QUOTED,
        Patterns::NUMBER,
        Patterns::LINE_COMMENT,
        Patterns::BLOCK_COMMENT,
      ).freeze,
      cassandra: Regexp.union(
        Patterns::SINGLE_QUOTED,
        Patterns::UUID,
        Patterns::NUMBER,
        Patterns::BOOLEAN,
        Patterns::HEXADECIMAL,
        Patterns::LINE_COMMENT,
        Patterns::BLOCK_COMMENT,
      ).freeze,
      default: Regexp.union(
        Patterns::SINGLE_QUOTED,
        Patterns::DOUBLE_QUOTED,
        Patterns::DOLLAR_QUOTED,
        Patterns::UUID,
        Patterns::NUMBER,
        Patterns::BOOLEAN,
        Patterns::HEXADECIMAL,
        Patterns::LINE_COMMENT,
        Patterns::BLOCK_COMMENT,
        Patterns::ORACLE_QUOTED,
      ).freeze,
    }.freeze

    def self.pattern(db)
      PATTERNS[db] || PATTERNS[:default]
    end

    PAIRS = {
      mysql: Regexp.union(
        Pairs::SINGLE_QUOTED,
        Pairs::DOUBLE_QUOTED,
        Pairs::BLOCK_COMMENT,
      ),
      postgres: Regexp.union(
        Pairs::SINGLE_QUOTED,
        Pairs::DOLLAR_QUOTED,
        Pairs::BLOCK_COMMENT,
      ),
      sqlite: Regexp.union(
        Pairs::SINGLE_QUOTED,
        Pairs::BLOCK_COMMENT,
      ),
      cassandra: Regexp.union(
        Pairs::SINGLE_QUOTED,
        Pairs::BLOCK_COMMENT,
      ),
      oracle: Regexp.union(
        Pairs::SINGLE_QUOTED,
        Pairs::BLOCK_COMMENT,
      ),
      default: Regexp.union(
        Pairs::SINGLE_QUOTED,
        Pairs::DOUBLE_QUOTED,
        Pairs::BLOCK_COMMENT,
      ),
    }.freeze

    def self.pairs(db)
      PAIRS[db] || PAIRS[:default]
    end
  end
end
