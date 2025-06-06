source "https://rubygems.org"

ruby "3.3.5"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.5", ">= 7.1.5.1"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Vite.js integration in Ruby web apps [https://vite-ruby.netlify.app/]
gem "vite_rails"

# Rails forms made easy [https://github.com/heartcombo/simple_form]
gem "simple_form", "~> 5.3"

# Devise for authentication [https://github.com/heartcombo/devise]
gem "devise", "~> 4.9"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Load environment variables from .env into ENV in development [https://github.com/bkeepers/dotenv]
  gem "dotenv-rails", "~> 3.1"

  # generate realistic fake data [https://github.com/faker-ruby/faker]
  gem "faker", "~> 3.5"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Watches your queries for when you should add eager loading (N+1 queries) [https://github.com/flyerhzm/bullet]
  gem 'bullet'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

# Silence warning: ostruct.rb was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.5.0.
# This app never uses an open struct anyway, at least not in my code. I just want to get rid of that warning.
gem "ostruct", "~> 0.6.1"

# Easy Postgresql full text search with ActiveRecord [https://github.com/Casecommons/pg_search]
gem "pg_search", "~> 2.3"

# Solid Queue is a DB-based queuing backend for Active Job [https://github.com/rails/solid_queue]
gem "solid_queue", "~> 1.1"

# Pagination [https://github.com/ddnexus/pagy]
gem "pagy", "~> 9.3"

# Authorization [https://github.com/varvet/pundit]
gem "pundit", "~> 2.5"
