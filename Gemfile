source "https://rubygems.org"

gem "gds-sso", "~> 14.3"
gem "govuk_app_config", "~> 2"
gem "plek", "~> 3"
gem "rails", "~> 5.2"

gem "mongo", "~> 2.4.3"
gem "mongoid", "~> 6.2"
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

group :development, :test do
  gem "byebug", "~> 11"
  gem "ci_reporter_rspec", "~> 1.0"
  gem "climate_control", "~> 0.2"
  gem "database_cleaner", "~> 1.8"
  gem "factory_bot_rails", "~> 5.1"
  gem "rubocop-govuk"
  gem "rack-handlers", "~> 0.7", require: "rack/handler/rails-server"
  gem "rspec-rails", "~> 3.9"
  gem "webmock", "~> 3.8", require: false
end
