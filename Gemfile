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

group :development, :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '~>3.5'
  gem 'pry'
  gem 'pry-rails'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'tzinfo-data'
end
