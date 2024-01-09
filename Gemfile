# frozen_string_literal: true

source "https://rubygems.org"

gem 'pry-byebug', platform: :mri

gemspec

eval_gemfile "gemfiles/rubocop.gemfile"
eval_gemfile "gemfiles/rbs.gemfile"

group :test do
  gem 'activefunction-core', path: './gems/activefunction-core'
  gem 'mocha'
end 

local_gemfile = "#{File.dirname(__FILE__)}/Gemfile.local"

eval(File.read(local_gemfile)) if File.exist?(local_gemfile) # rubocop:disable Security/Eval
