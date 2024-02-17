# frozen_string_literal: true

require "fileutils"
require "rake/testtask"
require "rubocop/rake_task"

REPO_ROOT = File.dirname(__FILE__)
GEMS_DIR  = "#{REPO_ROOT}/gems"
GEMS_DIRS = (Dir.glob("#{GEMS_DIR}/*") + Dir.glob(REPO_ROOT))

Dir.glob("#{REPO_ROOT}/tasks/**/*.rake").each do |task_file|
  load(task_file)
end

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
    t.warning    = false
    t.verbose    = true
    t.test_files = FileList["#{gem_dir}/test/**/*_test.rb"].then do |test_files|
      if RUBY_VERSION >= "3.2"
        test_files
      else
        test_files.exclude("#{gem_dir}/test/functions/aws_lambda/**/*.rb")
      end
    end
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

desc "Rubocop all gems"
task "rubocop:all" do
  with_all_gems do |name|
    Rake::Task["rubocop:#{name}"].invoke
  end
end

desc "Rubocop single gem"
task "rubocop:gem", [:gem_name] do |_, args|
  Rake::Task["rubocop:#{gem_name(args[:gem_name])}"].invoke
end

desc "Transpile all gems"
task "nextify:all" do
  with_all_gems(false) do |path|
    sh "bundle exec ruby-next nextify #{path}/lib -V"
  end
end

desc "Transpile single gem"
task "nextify:gem", [:gem_name] do |_, args|
  sh "cd #{args[:gem_name]} && bundle exec ruby-next nextify -V"
end
