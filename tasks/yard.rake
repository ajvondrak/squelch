# frozen_string_literal: true

require "yard"
require "yard/rake/yardoc_task"

YARD::Rake::YardocTask.new do |yard|
  yard.stats_options = ["--list-undoc", "--compact"]
end
