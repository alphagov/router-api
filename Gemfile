source "https://rubygems.org"

gem "rails", "7.0.4"

gem "gds-sso"
gem "govuk_app_config"
gem "mail", "~> 2.7.1"  # TODO: remove once https://github.com/mikel/mail/issues/1489 is fixed.
gem "plek"

gem "mongo", "~> 2.15.1"
gem "mongoid"

group :development, :test do
  gem "brakeman"
  gem "byebug"
  gem "ci_reporter_rspec"
  gem "climate_control"
  gem "database_cleaner-mongoid"
  gem "factory_bot_rails"
  gem "rack-handlers", require: "rack/handler/rails-server"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov"
  gem "webmock", require: false
end
