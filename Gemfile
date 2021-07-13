source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.1.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'rack-cors', require: 'rack/cors'
gem 'bcrypt'
gem 'jwt'
gem 'sendgrid-ruby'
gem 'haml-rails', '~> 2.0'
gem 'faker'
gem 'rolify'
gem 'cancancan'
gem 'rubyXL'
gem 'google_drive'
gem 'google-cloud-storage'
gem 'pg_search'
gem 'draper'
gem 'caracal-rails'
gem 'rubocop'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'spreadsheet'
gem 'redis'
gem 'acts_as_paranoid', '~> 0.7.0'
gem 'image_processing', '~> 1.2'
gem 'active_storage_validations'
gem 'mini_magick', '>= 4.9.5'

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'letter_opener'
  gem 'factory_bot_rails'
end

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec-rails', '~>3.5'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-collection_matchers'
  gem 'rspec-sidekiq'
  gem 'sidekiq-status'
end

gem 'sidekiq'
gem 'sinatra', github: 'sinatra/sinatra'
