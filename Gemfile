source 'https://rubygems.org'

gem 'govuk_app_config', '~> 1'
gem 'plek', '~> 2'
gem 'rails', '~> 5.2'

gem 'mongo', '~> 2.4.3'
gem 'mongoid', '~> 6.2'
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

group :development, :test do
  gem 'byebug', '~> 10'
  gem 'ci_reporter_rspec', '~> 1.0'
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'govuk-lint', '~> 3.8'
  gem 'rack-handlers', '~> 0.7', require: 'rack/handler/rails-server'
  gem 'rspec-rails', '~> 3.5'
  gem 'webmock', '~> 3.4', require: false
end
