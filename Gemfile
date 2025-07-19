# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '8.0.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.6'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem 'stimulus-rails'

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem 'jbuilder'
gem 'alba'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.4'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'
gem 'mini_magick'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'bullet'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'spring-commands-rspec'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'erb_lint'
  gem 'hotwire-livereload'
  gem 'htmlbeautifier'
  gem 'i18n_generators'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'spring'
end

group :test do
  gem 'capybara', github: 'teamcapybara/capybara'
  gem 'selenium-webdriver'
end

gem 'acts-as-taggable-on'
gem 'dotenv-rails'
gem 'enum_help'
gem 'google-analytics-data-v1beta'
gem 'meta-tags'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pagy'
gem 'sitemap_generator'
gem 'whenever', require: false
gem 'x'
