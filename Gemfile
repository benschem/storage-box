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

# Every environment except production
group :development, :staging, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Load environment variables from .env into ENV in development [https://github.com/bkeepers/dotenv]
  gem "dotenv-rails", "~> 3.1"

  # Don't send real emails outside of production [https://github.com/ryanb/letter_opener]
  gem "letter_opener", "~> 1.10"
end

group :development, :test do
  # Rspec is a drop-in alternative to Rails default testing framework, Minitest
  gem 'rspec-rails', '~> 7.0.0'

  # Useful for manual factory testing in console
  gem 'factory_bot_rails'

  # Generate realistic fake data [https://github.com/faker-ruby/faker]
  gem "faker", "~> 3.5"

  # Pretty print your Ruby objects with style -- in full color and with proper indentation [https://github.com/awesome-print/awesome_print]
  gem 'awesome_print'

  # A Ruby static code analyzer and formatter, based on the community Ruby style guide [https://github.com/rubocop/rubocop]
  gem 'rubocop', '~> 1.78'

  # rubocop-capybara [https://rubygems.org/gems/rubocop-capybara]
  gem 'rubocop-capybara', '~> 2.22'

  # rubocop-factory_bot [https://rubygems.org/gems/rubocop-factory_bot]
  gem 'rubocop-factory_bot', '~> 2.27'

  # rubocop-rails [https://rubygems.org/gems/rubocop-rails]
  gem 'rubocop-rails', '~> 2.32'

  # rubocop-rspec [https://rubygems.org/gems/rubocop-rspec]
  gem 'rubocop-rspec', '~> 3.6'

  # rubocop-rspec_rails [https://rubygems.org/gems/rubocop-rspec_rails]
  gem 'rubocop-rspec_rails', '~> 2.31'

  # rubocop-performance [https://github.com/rubocop/rubocop-performance]
  gem 'rubocop-performance', '~> 1.25'
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

  # Simple one-liner tests for common Rails functionality [https://github.com/thoughtbot/shoulda-matchers]
  gem 'shoulda-matchers', '~> 6.0'

  # A set of RSpec matchers for testing Pundit authorisation policies. [https://github.com/pundit-community/pundit-matchers]
  gem 'pundit-matchers', '~> 4.0'
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
