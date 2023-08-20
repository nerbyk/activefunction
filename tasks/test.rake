require "rake/testtask"
require "rubocop/rake_task"


def gem_name(dir)
  File.basename(dir)
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
  GEMS_DIRS.each do |gem_dir|
    Rake::Task["test_gem:#{gem_name(gem_dir)}"].invoke
  end
end

desc "Run Specs for single gem"
task "test:gem", [:gem_name] do |_, args|
  Rake::Task["test_gem:#{gem_name(args[:gem_name])}"].invoke
end

desc "Check Rubocop for all gems"
task "rubocop:all" do
  GEMS_DIRS.each do |gem_dir|
    Rake::Task["rubocop:#{gem_name(gem_dir)}"].invoke
  end
end

desc "Check Rubocop for single gem"
task "rubocop:gem", [:gem_name] do |_, args|
  Rake::Task["rubocop:#{gem_name(args[:gem_name])}"].invoke
end

desc "Check Ruby Next for all gems"
task "nextify:all" do
  GEMS_DIRS.each do |gem_dir|
    sh "bundle exec ruby-next nextify #{gem_dir} -V"
  end
end

desc "Check Ruby Next for single gem"
task "nextify:gem", [:gem_name] do |_, args|
  sh "cd #{args[:gem_name]} && bundle exec ruby-next nextify -V"
end

