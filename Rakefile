# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
 
Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning    = false
  t.verbose    = true
end

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new do |t|
    t.options = ["-a"]
  end
rescue LoadError
  task(:rubocop) {}
end

RuboCop::RakeTask.new

task :steep do
  require "steep"
  require "steep/cli"

  Steep::CLI.new(argv: ["check"], stdout: $stdout, stderr: $stderr, stdin: $stdin).run
end

namespace :steep do
  task :stats do
    exec "bundle exec steep stats --log-level=fatal --format=table'"
  end
end

task default: %i[test rubocop steep]
