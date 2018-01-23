source 'https://rubygems.org'

gem 'govuk_app_config'
gem 'plek', '2.1.1'
gem 'rails', '5.1.1'

gem 'mongoid', '~> 6.2'
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

group :development, :test do
  gem 'byebug'
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'database_cleaner', '1.6.2'
  gem 'factory_girl_rails', '4.2.1'
  gem 'govuk-lint', '3.6.0'
  gem 'rack-handlers', '~> 0.7', require: 'rack/handler/rails-server'
  gem 'rspec-rails', '~> 3.5'
  gem 'webmock', '~> 3.3.0', require: false
end
