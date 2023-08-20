
# frozen_string_literal: true

desc 'Builds gems by name'
task 'gems:build', [:gem_name] do |_, args|
  gem_name = args[:gem_name]
  current_dir = FileUtils.pwd

  raise "Gem #{gem_name} not found" unless Dir.exist?("#{$GEMS_DIR}/#{gem_name}")

  Dir.chdir("#{$GEMS_DIR}/#{gem_name}") do
    version = File.read('VERSION').strip
    sh("gem build #{gem_name}.gemspec")
    FileUtils.mv("#{gem_name}-#{version}.gem", current_dir)
  end
end
