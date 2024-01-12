# frozen_string_literal: true

source "https://rubygems.org"

gem 'pry-byebug', platform: :mri

gemspec

eval_gemfile "gemfiles/rubocop.gemfile"
eval_gemfile "gemfiles/rbs.gemfile"


group :development, :test do
  gem "rake", ">= 13.0"
  gem "ruby-next", ">= 1.0.0"
  # gem 'activefunction-core', path: './gems/activefunction-core'
end

group :test do
  gem 'mocha'
  gem 'pry-byebug'
  gem "minitest", "~> 5.15.0"
  gem "minitest-reporters", "~> 1.4.3"
end 

local_gemfile = "#{File.dirname(__FILE__)}/Gemfile.local"

eval(File.read(local_gemfile)) if File.exist?(local_gemfile) # rubocop:disable Security/Eval
