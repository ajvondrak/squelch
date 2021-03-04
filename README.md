# Squelch

Squelch squelches SQL!

```sql
-- Before
INSERT INTO users(name, address, phone) VALUES ("John Doe", "1600 Pennsylvania Ave", "867-5309");
```
```sql
-- After
INSERT INTO users(name, address, phone) VALUES (?, ?, ?);
```

This gem is a purposefully simple string obfuscator. It aims to replace every data literal in a SQL query with a `?` placeholder, as though it were a prepared statement. The result should still be readable SQL, but without the risk of leaking potentially sensitive information.

The code was originally adapted from the [`NewRelic::Agent::Database::ObfuscationHelpers`](https://github.com/newrelic/newrelic-ruby-agent/blob/f0290ab6468ad205dd014d63c794883dc47eebe7/lib/new_relic/agent/database/obfuscation_helpers.rb) in the [newrelic\_rpm](https://rubygems.org/gems/newrelic_rpm) gem. By abstracting out these low-level implementation details, the hope is that Squelch can empower other libraries to safely collect their own SQL logs.

## Installation
TODO

## Usage
TODO
