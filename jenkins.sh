#!/bin/bash -x
set -e

export RAILS_ENV=test
export GOVUK_APP_DOMAIN=test.alphagov.gov.uk

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec rake db:drop
bundle exec rake ci:setup:rspec default

# Run seeds twice to ensure they work with pre-existing data
SKIP_RELOAD_ROUTES_FROM_SEEDS=1 bundle exec rake db:seed
SKIP_RELOAD_ROUTES_FROM_SEEDS=1 bundle exec rake db:seed
