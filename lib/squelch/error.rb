# frozen_string_literal: true

module Squelch
  # Raised by {Squelch.obfuscate!} if the SQL appears to have been malformed.
  class Error < StandardError
    attr_reader :obfuscation

    def initialize(match)
      @obfuscation = match.string
      delimiter = match.to_s
      super(<<~MSG)
        Failed to squelch SQL, delimiter #{delimiter} remained after obfuscation
      MSG
    end
  end
end
