# frozen_string_literal: true

require "test_helper"

# rubocop:disable Layout/LineLength

class SquelchTest < Minitest::Test
  def test_version
    refute_nil Squelch::VERSION
  end

  def assert_obfuscates(sql:, obf:, dbs:)
    dbs.each do |db|
      assert_includes obf, Squelch.obfuscate(sql, db: db)
    end
  end

  ### BEGIN NEW RELIC TESTS ###

  def test_back_quoted_identifiers_mysql
    assert_obfuscates(
      sql: "SELECT `t001`.`c2` FROM `t001` WHERE `t001`.`c2` = 'value' AND c3=\"othervalue\" LIMIT ?",
      obf: ["SELECT `t001`.`c2` FROM `t001` WHERE `t001`.`c2` = ? AND c3=? LIMIT ?"],
      dbs: %i[mysql],
    )
  end

  def test_comment_delimiters_in_double_quoted_strings
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE foo=\"bar/*\" AND baz=\"whatever */qux\"",
      obf: ["SELECT * FROM t WHERE foo=? AND baz=?"],
      dbs: %i[mssql mysql],
    )
  end

  def test_comment_delimiters_in_single_quoted_strings
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE foo='bar/*' AND baz='whatever */qux'",
      obf: ["SELECT * FROM t WHERE foo=? AND baz=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_double_quoted_identifiers_postgres
    assert_obfuscates(
      sql: "SELECT \"t001\".\"c2\" FROM \"t001\" WHERE \"t001\".\"c2\" = 'value' AND c3=1234 LIMIT 1",
      obf: ["SELECT \"t001\".\"c2\" FROM \"t001\" WHERE \"t001\".\"c2\" = ? AND c3=? LIMIT ?"],
      dbs: %i[postgres oracle],
    )
  end

  def test_end_of_line_comment_in_double_quoted_string
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE foo=\"bar--\" AND\n  baz=\"qux--\"",
      obf: ["SELECT * FROM t WHERE foo=? AND\n  baz=?"],
      dbs: %i[mssql mysql],
    )
  end

  def test_end_of_line_comment_in_single_quoted_string
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE foo='bar--' AND\n  baz='qux--'",
      obf: ["SELECT * FROM t WHERE foo=? AND\n  baz=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_end_of_query_comment_cstyle
    assert_obfuscates(
      sql: "SELECT * FROM foo WHERE bar='baz' /* Hide Me */",
      obf: ["SELECT * FROM foo WHERE bar=? ?", "SELECT * FROM foo WHERE bar=? "],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_end_of_query_comment_doubledash
    assert_obfuscates(
      sql: "SELECT * FROM foobar WHERE password='hunter2'\n-- No peeking!",
      obf: ["SELECT * FROM foobar WHERE password=?\n?", "SELECT * FROM foobar WHERE password=?\n"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_end_of_query_comment_hash
    assert_obfuscates(
      sql: "SELECT foo, bar FROM baz WHERE password='hunter2' # Secret",
      obf: ["SELECT foo, bar FROM baz WHERE password=? ?", "SELECT foo, bar FROM baz WHERE password=? "],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_escape_string_constants_postgres
    assert_obfuscates(
      sql: "SELECT \"col1\", \"col2\" from \"table\" WHERE \"col3\"=E'foo\\'bar\\\\baz' AND country=e'foo\\'bar\\\\baz'",
      obf: ["SELECT \"col1\", \"col2\" from \"table\" WHERE \"col3\"=E?", "SELECT \"col1\", \"col2\" from \"table\" WHERE \"col3\"=E? AND country=e?"],
      dbs: %i[postgres],
    )
  end

  def test_multiple_literal_types_mysql
    assert_obfuscates(
      sql: "INSERT INTO `X` values(\"test\",0, 1 , 2, 'test')",
      obf: ["INSERT INTO `X` values(?,?, ? , ?, ?)"],
      dbs: %i[mysql],
    )
  end

  def test_numbers_in_identifiers
    assert_obfuscates(
      sql: "SELECT c11.col1, c22.col2 FROM table c11, table c22 WHERE value='nothing'",
      obf: ["SELECT c11.col1, c22.col2 FROM table c11, table c22 WHERE value=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_numeric_literals
    assert_obfuscates(
      sql: "INSERT INTO X VALUES(1, 23456, 123.456, 99+100)",
      obf: ["INSERT INTO X VALUES(?, ?, ?, ?+?)", "INSERT INTO X VALUES(?, ?, ?.?, ?+?)"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_double_quoted_mysql
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE name=\"foo\" AND value=\"don't\"",
      obf: ["SELECT * FROM table WHERE name=? AND value=?"],
      dbs: %i[mysql],
    )
  end

  def test_string_single_quoted
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE name='foo' AND value = 'bar'",
      obf: ["SELECT * FROM table WHERE name=? AND value = ?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_backslash_and_twin_single_quotes
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE col='foo\\''bar'",
      obf: ["SELECT * FROM table WHERE col=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_embedded_double_quote
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE col1='foo\"bar' AND col2='what\"ever'",
      obf: ["SELECT * FROM table WHERE col1=? AND col2=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_embedded_newline
    assert_obfuscates(
      sql: "select * from accounts where accounts.name != 'dude \n newline' order by accounts.name",
      obf: ["select * from accounts where accounts.name != ? order by accounts.name"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_embedded_single_quote_mysql
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE col1=\"don't\" AND col2=\"won't\"",
      obf: ["SELECT * FROM table WHERE col1=? AND col2=?"],
      dbs: %i[mysql],
    )
  end

  def test_string_with_escaped_quotes_mysql
    assert_obfuscates(
      sql: "INSERT INTO X values('', 'jim''s ssn',0, 1 , 'jim''s son''s son', \"\"\"jim''s\"\" hat\", \"\\\"jim''s secret\\\"\")",
      obf: ["INSERT INTO X values(?, ?,?, ? , ?, ?, ?", "INSERT INTO X values(?, ?,?, ? , ?, ?, ?)"],
      dbs: %i[mysql],
    )
  end

  def test_string_with_trailing_backslash
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE name='foo\\' AND color='blue'",
      obf: ["SELECT * FROM table WHERE name=?", "SELECT * FROM table WHERE name=? AND color=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_trailing_escaped_backslash_mysql
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE foo=\"this string ends with a backslash\\\\\"",
      obf: ["SELECT * FROM table WHERE foo=?"],
      dbs: %i[mysql],
    )
  end

  def test_string_with_trailing_escaped_backslash_single_quoted
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE foo='this string ends with a backslash\\\\'",
      obf: ["SELECT * FROM table WHERE foo=?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_trailing_escaped_quote
    assert_obfuscates(
      sql: "SELECT * FROM table WHERE name='foo\\'' AND color='blue'",
      obf: ["SELECT * FROM table WHERE name=?", "SELECT * FROM table WHERE name=? AND color=?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_string_with_twin_single_quotes
    assert_obfuscates(
      sql: "INSERT INTO X values('', 'a''b c',0, 1 , 'd''e f''s h')",
      obf: ["INSERT INTO X values(?, ?,?, ? , ?)"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_pathological_end_of_line_comments_with_quotes
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE -- '\n  bar='baz' -- '",
      obf: ["SELECT * FROM t WHERE ?\n  bar=? ?", "SELECT * FROM t WHERE ?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_pathological_mixed_comments_and_quotes
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE /* ' */ \n  bar='baz' -- '",
      obf: ["SELECT * FROM t WHERE ? \n  bar=? ?", "SELECT * FROM t WHERE ?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_pathological_mixed_quotes_comments_and_newlines
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE -- '\n  /* ' */ c2='xxx' /* ' */\n  c='x\n  xx' -- '",
      obf: ["SELECT * FROM t WHERE ?\n  ? c2=? ?\n  c=? ?", "SELECT * FROM t WHERE ?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_pathological_mixed_quotes_end_of_line_comments
    assert_obfuscates(
      sql: "SELECT * FROM t WHERE -- '\n  c='x\n  xx' -- '",
      obf: ["SELECT * FROM t WHERE ?\n  c=? ?", "SELECT * FROM t WHERE ?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_pathological_quote_delimiters_in_comments
    assert_obfuscates(
      sql: "SELECT * FROM foo WHERE col='value1' AND /* don't */ col2='value1' /* won't */",
      obf: ["SELECT * FROM foo WHERE col=? AND ? col2=? ?", "SELECT * FROM foo WHERE col=? AND ?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_dollar_quotes
    assert_obfuscates(
      sql: "SELECT * FROM \"foo\" WHERE \"foo\" = $a$dollar quotes can be $b$nested$b$$a$ and bar = 'baz'",
      obf: ["SELECT * FROM \"foo\" WHERE \"foo\" = ? and bar = ?"],
      dbs: %i[postgres],
    )
  end

  def test_variable_substitution_not_mistaken_for_dollar_quotes
    assert_obfuscates(
      sql: "INSERT INTO \"foo\" (\"bar\", \"baz\", \"qux\") VALUES ($1, $2, $3) RETURNING \"id\"",
      obf: ["INSERT INTO \"foo\" (\"bar\", \"baz\", \"qux\") VALUES ($?, $?, $?) RETURNING \"id\""],
      dbs: %i[postgres],
    )
  end

  def test_non_quote_escape
    assert_obfuscates(
      sql: "select * from foo where bar = 'some\\tthing' and baz = 10",
      obf: ["select * from foo where bar = ? and baz = ?"],
      dbs: %i[mssql mysql postgres oracle cassandra sqlite],
    )
  end

  def test_end_of_string_backslash_and_line_comment_with_quite
    assert_obfuscates(
      sql: "select * from users where user = 'user1\\' password = 'hunter 2' -- ->don't count this quote",
      obf: ["select * from users where user = ?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_oracle_bracket_quote
    assert_obfuscates(
      sql: "select * from foo where bar=q'[baz's]' and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[oracle],
    )
  end

  def test_oracle_brace_quote
    assert_obfuscates(
      sql: "select * from foo where bar=q'{baz's}' and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[oracle],
    )
  end

  def test_oracle_angle_quote
    assert_obfuscates(
      sql: "select * from foo where bar=q'<baz's>' and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[oracle],
    )
  end

  def test_oracle_paren_quote
    assert_obfuscates(
      sql: "select * from foo where bar=q'(baz's)' and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[oracle],
    )
  end

  def test_cassandra_blobs
    assert_obfuscates(
      sql: "select * from foo where bar=0xabcdef123 and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[cassandra sqlite],
    )
  end

  def test_hex_literals
    assert_obfuscates(
      sql: "select * from foo where bar=0x2F and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[mysql cassandra sqlite],
    )
  end

  def test_exponential_literals
    assert_obfuscates(
      sql: "select * from foo where bar=1.234e-5 and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_negative_integer_literals
    assert_obfuscates(
      sql: "select * from foo where bar=-1.234e-5 and x=-5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[mysql postgres oracle cassandra sqlite],
    )
  end

  def test_uuid
    assert_obfuscates(
      sql: "select * from foo where bar=01234567-89ab-cdef-0123-456789abcdef and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[postgres cassandra],
    )
  end

  def test_uuid_with_braces
    assert_obfuscates(
      sql: "select * from foo where bar={01234567-89ab-cdef-0123-456789abcdef} and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[postgres],
    )
  end

  def test_uuid_no_dashes
    assert_obfuscates(
      sql: "select * from foo where bar=0123456789abcdef0123456789abcdef and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[postgres],
    )
  end

  def test_uuid_random_dashes
    assert_obfuscates(
      sql: "select * from foo where bar={012-345678-9abc-def012345678-9abcdef} and x=5",
      obf: ["select * from foo where bar=? and x=?"],
      dbs: %i[postgres],
    )
  end

  def test_booleans
    assert_obfuscates(
      sql: "select * from truestory where bar=true and x=FALSE",
      obf: ["select * from truestory where bar=? and x=?"],
      dbs: %i[mysql postgres cassandra sqlite],
    )
  end

  def test_in_clause_digits
    assert_obfuscates(
      sql: "select * from foo where bar IN (123, 456, 789)",
      obf: ["select * from foo where bar IN (?, ?, ?)"],
      dbs: %i[mysql postgres oracle cassandra mssql],
    )
  end

  def test_in_clause_strings
    assert_obfuscates(
      sql: "select * from foo where bar IN ('asdf', 'fdsa')",
      obf: ["select * from foo where bar IN (?, ?)"],
      dbs: %i[mysql postgres oracle cassandra mssql],
    )
  end

  def test_unterminated_double_quoted_string
    sql = "SELECT * FROM table WHERE foo='bar' AND baz=\"nothing to see here"
    assert_raises(Squelch::Error) { Squelch.obfuscate!(sql, db: :mysql) }
    assert_equal "?", Squelch.obfuscate(sql, db: :mysql)
  end

  def test_unterminated_single_quoted_string
    sql = "SELECT * FROM table WHERE foo='bar' AND baz='nothing to see here"
    %i[mysql postgres oracle cassandra sqlite].each do |db|
      assert_raises(Squelch::Error) { Squelch.obfuscate!(sql, db: db) }
      assert_equal "?", Squelch.obfuscate(sql, db: db)
    end
  end

  ### END NEW RELIC TESTS ###

  def test_nested_comments # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    assert_equal "?", Squelch.obfuscate!("/**/")
    assert_equal "?", Squelch.obfuscate!("/***/")
    assert_equal "?", Squelch.obfuscate!("/*/*/")
    assert_equal "?", Squelch.obfuscate!("/* with/slashes */")
    assert_equal "?", Squelch.obfuscate!("/* /* a */ */")
    assert_equal "?", Squelch.obfuscate!("/* /*a*/ /*b*/ */")
    assert_equal "?", Squelch.obfuscate!("/* a /* b /* c */ */ */")
    assert_equal "?", Squelch.obfuscate!("/* /* a /* b */ */ c */")

    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* a") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("a */") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* a /* */") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* */ a */") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* a */ */") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("*/ /* a */") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* a /* /*") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* */ a /*") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("/* a */ /*") }
    assert_raises(Squelch::Error) { Squelch.obfuscate!("*/ /* a */") }
  end
end

# rubocop:enable Layout/LineLength
