# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:test)

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start { add_filter "test" }

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require "squelch"
require "minitest/autorun"
