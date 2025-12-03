# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.4.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.1"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Libraries and utilities
gem "active_storage_validations", "~> 3.0"
gem "amazing_print", "~> 2.0"
gem "blake3-rb", "~> 1.5"
gem "dotenv-rails", "~> 3.2"
gem "hashdiff", "~> 1.2"
gem "hiredis-client", "~> 0.26"
gem "irb", "~> 1.15"
gem "jsonb_accessor", "~> 1.4"
gem "jsonpath", "~> 1.1"
gem "lru_redux", "~> 1.1"
gem "oj", "~> 3.16"
gem "rails-healthcheck", "~> 1.4"
gem "redis", "~> 5.4"
gem "validate_url", "~> 1.0"
gem "zstd-ruby", "~> 2.0"

## Gems needed to generate the seeds
gem "factory_bot_rails", "~> 6.5", require: false
gem "faker", "~> 3.5", require: false

group :development do
  # Profiling, auditing, and performance tools
  gem "bullet", "~> 8.1"
  gem "flamegraph", "~> 0.9"
  gem "memory_profiler", "~> 1.1"
  gem "rack-mini-profiler", "~> 4.0", require: false
  gem "stackprof", "~> 0.2"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "better_errors", "~> 2.10"
  gem "web-console", "~> 4.2"

  # Linter
  gem "ordinare", "~> 0.4", require: false
  gem "rubocop-factory_bot", "~> 2.28", require: false
  gem "rubocop-faker", "~> 1.3", require: false
  gem "rubocop-rake", "~> 0.7", require: false
  gem "rubocop-rspec", "~> 3.8", require: false
  gem "rubocop-rspec_rails", "~> 2.32", require: false
  gem "rubocop-thread_safety", "~> 0.7", require: false
  gem "standard-rails", "~> 1.5", require: false
  ## Solargraph
  gem "solargraph-rails", "~> 1.2", require: false
  gem "solargraph-rspec", "~> 0.5", require: false
  gem "solargraph-standardrb", "~> 0.0", require: false
end

group :test do
  gem "rspec-collection_matchers", "~> 1.2"
  gem "shoulda-matchers", "~> 7.0"
  gem "spring-commands-rspec", "~> 1.0", require: false
  gem "super_diff", "~> 0.15"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Debugging and reflection
  gem "binding_of_caller", "~> 1.0"

  # Gems to improve development
  gem "rspec-rails", "~> 8.0"
  gem "spring", "~> 4.4"
  gem "spring-watcher-listen", "~> 2.1"
end
