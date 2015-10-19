#!/bin/bash -x
set -e

export RAILS_ENV=test
export GOVUK_APP_DOMAIN=test.alphagov.gov.uk

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

if [[ ${GIT_BRANCH} != "origin/master" ]]; then
  bundle exec govuk-lint-ruby \
    --rails \
    --display-cop-names \
    --display-style-guide \
    --format html --out rubocop-${GIT_COMMIT}.html \
    --format clang
fi

bundle exec rake ci:setup:rspec default

# Run seeds twice to ensure they work with pre-existing data
bundle exec rake db:seed
bundle exec rake db:seed
