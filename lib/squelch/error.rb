# frozen_string_literal: true

module Squelch
  # Raised by {Squelch.obfuscate!} if obfuscation seems to have failed.
  #
  # This might be raised either because the SQL was malformed in the first
  # place or because of a bug in our parsing. See {Squelch} for more
  # discussion.
  class Error < StandardError
    # @return [String] the original SQL input
    attr_reader :sql

    # @return [String] the invalid result of obfuscating {#sql}
    attr_reader :obfuscation

    # @return [String] the left over delimiter detected in {#obfuscation}
    attr_reader :delimiter

    def initialize(sql, mismatched)
      @sql = sql
      @obfuscation = mismatched.string
      @delimiter = mismatched.to_s
      super(<<~MSG.strip)
        Failed to squelch SQL, delimiter #{delimiter} remained after obfuscation
      MSG
    end
  end
end
