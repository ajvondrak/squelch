# frozen_string_literal: true

require "squelch/version"
require "squelch/pairs"
require "squelch/patterns"
require "squelch/database"
require "squelch/error"

# A simple SQL obfuscator.
module Squelch
  def self.obfuscate!(sql, db: :default)
    sql.gsub(Database.pattern(db), "?").tap do |obfuscated|
      mismatched = obfuscated.match(Database.pairs(db))
      raise Error, mismatched if mismatched
    end
  end

  def self.obfuscate(sql, db: :default)
    obfuscate!(sql, db: db)
  rescue Error
    "?"
  end
end
