source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby '3.3.0'  # Temporarily commented for compatibility

# Core Rails
gem 'rails', '~> 7.2.0'
gem 'puma', '~> 6.4'
gem 'sprockets-rails'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'

# Database
gem 'pg', '~> 1.5'
gem 'redis', '~> 5.0'
gem 'connection_pool', '~> 2.4' # Pin for Ruby 3.3 compatibility

# Background Jobs
gem 'sidekiq', '~> 7.2'

# Assets / Sprockets
gem 'sassc-rails', '~> 2.1'

# Admin Panel
gem 'activeadmin', '~> 3.2'
gem 'arctic_admin' # Modern responsive theme for ActiveAdmin
gem 'devise', '~> 4.9'
gem 'cancancan', '~> 3.5'

# Authentication
gem 'omniauth', '~> 2.1'
gem 'omniauth-google-oauth2', '~> 1.1'

# Image Processing
gem 'image_processing', '~> 1.12'
gem 'mini_magick', '~> 4.12'

# Caching & Performance
gem 'rack-mini-profiler', '~> 3.1', group: :development
gem 'bullet', '~> 7.1', group: :development

# Geocoding & Location
gem 'geocoder', '~> 1.8'

# API & Serialization
gem 'jbuilder', '~> 2.13'
gem 'jsonapi-serializer', '~> 2.2'

# Utilities
gem 'dotenv-rails', '~> 2.8'
gem 'kaminari', '~> 1.2'
gem 'friendly_id', '~> 5.5'

# Security
gem 'rack-cors'
gem 'bcrypt', '~> 3.1'

# Development & Testing
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.3'
end

group :development do
  gem 'web-console', '>= 4.2.0'
  gem 'listen', '~> 3.8'
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


gem "dockerfile-rails", ">= 1.7", :group => :development
