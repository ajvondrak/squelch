# frozen_string_literal: true

require "bundler/setup"
require "squelch"
Bundler.require(:test)

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require "minitest/autorun"
