# frozen_string_literal: true

require_relative "lib/squelch/version"

Gem::Specification.new do |spec|
  spec.name = "squelch"
  spec.version = Squelch::VERSION
  spec.required_ruby_version = ">= 2.6.0"
  spec.homepage = "https://github.com/ajvondrak/squelch"
  spec.summary = "A simple SQL obfuscator"
  spec.description = <<~DESC
    Squelch squelches SQL!

    This gem is a purposefully simple string obfuscator. It aims to replace
    every data literal in a SQL query with a `?` placeholder, as though it were
    a prepared statement. The result should still be readable SQL, but without
    the risk of leaking potentially sensitive information.
  DESC
  spec.author = "Alex Vondrak"
  spec.email = "ajvondrak@gmail.com"
  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/ajvondrak/squelch/issues",
    "documentation_uri" => "https://rubydoc.info/github/ajvondrak/squelch/main",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
  }
end
