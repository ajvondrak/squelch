# frozen_string_literal: true

require "squelch/version"
require "squelch/pairs"
require "squelch/patterns"
require "squelch/database"
require "squelch/error"

# A simple SQL obfuscator.
#
# The goal of {Squelch} is to replace every data literal in any given SQL
# string with a placeholder `?`. This removes any potentially sensitive values
# by removing *all* values, making the SQL read like it was a prepared
# statement all along.
#
# However, this process might produce bad results if there's a bug or you give
# a malformed SQL query. One heuristic we use to try to catch these cases is to
# look at the end result: are there any unmatched delimiters left over? Since
# obfuscation should remove *all* strings and comments, any dangling quotes or
# `/*` markers or such would indicate that either:
#
# * the SQL query had mismatched delimiter pairs in the first place, or
# * the obfuscation patterns failed to parse all the data literals correctly.
#
# Either way, we should be cautious of using either the original or the
# improperly-obfuscated query, since both may still contain sensitive
# information. To deal with these issues, we have both the error-safe
# {Squelch.obfuscate} and the error-raising {Squelch.obfuscate!}.
#
# Both methods not only accept a string of SQL, but optionally a specific
# database driver. This is because certain databases have their own special
# syntax. For example, Postgres uses double quotes around table names and
# supports `$$dollar quoted$$` strings, whereas MySQL uses backticks around
# table names and supports `"double quoted"` strings.
#
# To stand the best chance of scrubbing all sensitive values from your SQL, you
# should provide the specific database that you're using. That way, {Squelch}
# can make tweaks to its internal pattern matching. The default just tries to
# match all possible special cases, but that may wind up obfuscating too much
# or even being less performant than a more specific option.
#
# @example Basic obfuscation
#   Squelch.obfuscate("SELECT * FROM examples WHERE name = 'basic';")
#   #=> "SELECT * FROM examples WHERE name = ?;"
#
# @example Malformed query
#   Squelch.obfuscate("SELECT * FROM examples WHERE name = ''malformed';")
#   #=> "?"
#
#   begin
#     Squelch.obfuscate!("SELECT * FROM examples WHERE name = ''malformed';")
#   rescue Squelch::Error => e
#     puts e.message
#     puts
#     puts e.obfuscation
#   end
#   # Failed to squelch SQL, delimiter ' remained after obfuscation
#   #
#   # SELECT * FROM examples WHERE name = ?malformed';
#
# @example Using database-specific syntax
#   Squelch.obfuscate(
#     'SELECT "examples".name FROM examples WHERE db = $$postgres$$;',
#     db: :mysql,
#   )
#   #=> "SELECT ?.name FROM examples WHERE db = $$postgres$$;"
#
#   Squelch.obfuscate(
#     'SELECT "examples".name FROM examples WHERE db = $$postgres$$;',
#     db: :postgres,
#   )
#   #=> 'SELECT "examples".name FROM examples WHERE db = ?;'
module Squelch
  # Obfuscates a SQL query.
  #
  # If the resulting obfuscation still has dangling delimiters left over, we
  # return a single placeholder for the whole query, `?`. In order to get more
  # information about such errors, you should use {.obfuscate!}.
  #
  # @param sql [String] an unobfuscated SQL query
  #
  # @param db [Symbol] the specific database syntax being used; supports
  #   `:mysql`, `:postgres`, `:sqlite`, `:oracle`, `:oracle`, or `:cassandra`,
  #   while anything else will be treated as `:default`
  #
  # @return [String] the obfuscated SQL query
  def self.obfuscate(sql, db: :default)
    obfuscate!(sql, db: db)
  rescue Error
    "?"
  end

  # Obfuscates a SQL query, raising an error if there are issues.
  #
  # If the resulting obfuscation still has dangling delimiters left over, we
  # raise {Squelch::Error} with more information about what went wrong. If you
  # don't care about the details and just want some canonical string output,
  # you should use {.obfuscate}.
  #
  # @param (see .obfuscate)
  # @return (see .obfuscate)
  # @raise [Squelch::Error] if obfuscation didn't remove all delimiters
  def self.obfuscate!(sql, db: :default)
    sql.gsub(Database.pattern(db), "?").tap do |obfuscated|
      mismatched = obfuscated.match(Database.pairs(db))
      raise Error.new(sql, mismatched) if mismatched
    end
  end
end
