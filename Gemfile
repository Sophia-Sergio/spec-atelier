source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
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
gem 'bullet'
gem 'draper'
gem 'caracal-rails'
gem 'rubocop'

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'letter_opener'
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
  gem 'factory_bot_rails'
  gem 'rspec-sidekiq'
  gem 'sidekiq-status'
end

gem 'sidekiq'
gem 'sinatra', github: 'sinatra/sinatra'
