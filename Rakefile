# frozen_string_literal: true

require "fileutils"

REPO_ROOT = File.dirname(__FILE__)
GEMS_DIR = "#{REPO_ROOT}/gems"
GEMS_DIRS = (Dir.glob("#{GEMS_DIR}/*") + Dir.glob(REPO_ROOT))

Dir.glob("#{REPO_ROOT}/tasks/**/*.rake").each do |task_file|
  load(task_file)
end
