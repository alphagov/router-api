source 'https://rubygems.org'

gem 'rails', '4.0.0'

gem 'mongo_mapper', '0.13.0.beta2'
gem 'bson_ext', '1.9.2'


group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'unicorn', '4.6.3'
gem 'exception_notification', '4.0.1'
gem 'aws-ses', '0.5.0', :require => 'aws/ses'

group :development, :test do
  gem 'rspec-rails', '2.14.0'
  gem 'database_cleaner', '1.2.0'
  gem 'factory_girl_rails', '4.2.1'
  gem 'simplecov-rcov', '0.2.3', :require => false
  gem 'ci_reporter', '1.9.0'
  gem 'webmock', '1.15.0', :require => false
end
