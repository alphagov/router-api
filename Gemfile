source 'https://rubygems.org'

gem 'rails', '5.1.1'

gem 'plek', '1.12.0'

gem 'mongoid', '6.1.0'
gem 'mongoid_rails_migrations', '~> 1.0.1'

gem 'logstasher', '0.6.2'
gem 'unicorn', '~> 4.9.0'

gem 'airbrake', github: 'alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'

group :development, :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'database_cleaner', '1.6.1'
  gem 'factory_girl_rails', '4.2.1'
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', '~> 1.20.4', require: false
  gem 'govuk-lint'
  gem 'byebug'
end
