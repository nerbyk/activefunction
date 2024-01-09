# frozen_string_literal: true

require "rake/testtask"
require "rubocop/rake_task"

def gem_name(dir)
  File.basename(dir)
end

def with_all_gems(name = true, &block)
  GEMS_DIRS.each { |gem_dir| yield name ? gem_name(gem_dir) : gem_dir }
end

GEMS_DIRS.each do |gem_dir|
  Rake::TestTask.new("test_gem:#{gem_name(gem_dir)}") do |t|
    t.libs << "#{gem_dir}/test"
    t.libs << "#{gem_dir}/lib"
    t.test_files = FileList["#{gem_dir}/test/**/*_test.rb"]
    t.warning    = false
    t.verbose    = true
  end

  RuboCop::RakeTask.new("rubocop:#{gem_name(gem_dir)}") do |t|
    t.patterns = ["#{gem_dir}/lib/**/*.rb", "#{gem_dir}/test/**/*.rb"]
  end
end

desc "Run All Tests in each gem"
task "test:all" do
  with_all_gems do |name|
    Rake::Task["test_gem:#{name}"].invoke
  end
end

desc "Run Specs for single gem"
task "test:gem", [:gem_name] do |_, args|
  Rake::Task["test_gem:#{gem_name(args[:gem_name])}"].invoke
end

desc "Check Rubocop for all gems"
task "rubocop:all" do
  with_all_gems do |name|
    Rake::Task["rubocop:#{name}"].invoke
  end
end

desc "Check Rubocop for single gem"
task "rubocop:gem", [:gem_name] do |_, args|
  Rake::Task["rubocop:#{gem_name(args[:gem_name])}"].invoke
end

desc "Check Ruby Next for all gems"
task "nextify:all" do
  with_all_gems(false) do |path|
    sh "bundle exec ruby-next nextify #{path}/lib -V"
  end
end

desc "Check Ruby Next for single gem"
task "nextify:gem", [:gem_name] do |_, args|
  sh "cd #{args[:gem_name]} && bundle exec ruby-next nextify -V"
end

desc "Transpile all gems"
task "transpile:all" do
  with_all_gems(false) do |path|
    sh "bundle exec bin/ruby-next nextify --transpile-mode=rewrite #{path}/lib -V"
  end
end
