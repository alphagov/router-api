#!/bin/bash -x
set -e

export RAILS_ENV=test
export GOVUK_APP_DOMAIN=test.alphagov.gov.uk

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec rake ci:setup:rspec default

# Run seeds twice to ensure they work with pre-existing data
bundle exec rake db:seed
bundle exec rake db:seed
