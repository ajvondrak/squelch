# Squelch

[![build](https://github.com/ajvondrak/squelch/workflows/build/badge.svg)](https://github.com/ajvondrak/squelch/actions?query=workflow%3Abuild)
[![coverage](https://coveralls.io/repos/github/ajvondrak/squelch/badge.svg?branch=main)](https://coveralls.io/github/ajvondrak/squelch?branch=main)
[![docs](https://inch-ci.org/github/ajvondrak/squelch.svg?branch=main)](https://inch-ci.org/github/ajvondrak/squelch)
[![gem](https://badge.fury.io/rb/squelch.svg)](https://badge.fury.io/rb/squelch)

Squelch squelches SQL!

```sql
-- Before
INSERT INTO users(name, address, phone) VALUES ("John Doe", "1600 Pennsylvania Ave", "867-5309");

-- After
INSERT INTO users(name, address, phone) VALUES (?, ?, ?);
```

This gem is a purposefully simple string obfuscator. It aims to replace every data literal in a SQL query with a `?` placeholder, as though it were a prepared statement. The result should still be readable SQL, but without the risk of leaking potentially sensitive information.

The code was originally adapted from the [`NewRelic::Agent::Database::ObfuscationHelpers`](https://github.com/newrelic/newrelic-ruby-agent/blob/f0290ab6468ad205dd014d63c794883dc47eebe7/lib/new_relic/agent/database/obfuscation_helpers.rb) in the [newrelic\_rpm](https://rubygems.org/gems/newrelic_rpm) gem. By abstracting out these low-level implementation details, the hope is that Squelch can empower other libraries to easily sanitize their SQL logs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "squelch"
```

and then install it with `bundle install`.

Alternatively, you could install it to your system's gems with:

```console
$ gem install squelch
```

## Usage

### Basic interface

The main API is the `Squelch.obfuscate` method, which takes in your SQL string and returns an obfuscated version of it.

```ruby
Squelch.obfuscate("SELECT * FROM social_security_cards WHERE number = 'pii';")

#=> "SELECT * FROM social_security_cards WHERE number = ?;"
```

This method is powered by regular expression patterns, some of which correspond to particular database systems. For example, Postgres supports a unique [dollar quoting](https://www.postgresql.org/docs/13/sql-syntax-lexical.html#SQL-SYNTAX-DOLLAR-QUOTING) syntax, while Oracle has its own [Q quoting](https://livesql.oracle.com/apex/livesql/file/content_CIREYU9EA54EOKQ7LAMZKRF6P.html) syntax. If possible, try to always supply the optional `db:` keyword parameter with a symbol corresponding to your RDMS. The currently supported options are `:mysql`, `:postgres`, `:sqlite`, `:oracle`, and `:cassandra`, but any other option will fall back safely to a generic default pattern.

```ruby
Squelch.obfuscate("SELECT * FROM credit_cards WHERE number = $pii$ ... $pii$;", db: :postgres)

#=> "SELECT * FROM credit_cards WHERE number = ?;"
```

```ruby
Squelch.obfuscate("SELECT * FROM phones WHERE number = q'<pii>';", db: :oracle)

#=> "SELECT * FROM phones WHERE number = ?;"
```

### Handling errors

When there's an issue with squelching the SQL, we don't want to risk of using the problematic results that might still be leaking PII. The error-safe `Squelch.obfuscate` method returns a single `?` placeholder in the event of an issue, but Squelch has the error-raising variant `Squelch.obfuscate!` as well.

```ruby
Squelch.obfuscate("SELECT * FROM table WHERE pii = 'a string missing a closing quote;")

#=> "?"
```

```ruby
Squelch.obfuscate!("SELECT * FROM table WHERE pii = 'a string missing a closing quote;")

#=> Squelch::Error: Failed to squelch SQL, delimiter ' remained after obfuscation
```

If you rescue the `Squelch::Error`, you can access the problematic obfuscation result in `Squelch::Error#obfuscation`.

```ruby
begin
  Squelch.obfuscate!("SELECT * FROM users WHERE id = 12345 AND name = 'Mister Danglin' Quote';")
rescue Squelch::Error => e
  e.obfuscation
end

#=> "SELECT * FROM users WHERE id = ? AND name = ? Quote';"
```

## Documentation

Full API documentation can be found [on RubyDoc.info](https://rubydoc.info/github/ajvondrak/squelch/main).
