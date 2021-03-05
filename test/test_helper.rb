# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:test)

Coveralls.wear!
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require "squelch"
require "minitest/autorun"
