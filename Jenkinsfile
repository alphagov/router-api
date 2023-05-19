#!/usr/bin/env groovy

library("govuk")

REPOSITORY = "postgres-router-api"

repoName = JOB_NAME.split('/')[0]

node {
  govuk.setEnvar("TEST_DATABASE_URL", "postgresql://postgres@127.0.0.1:54313/router-test")

  govuk.buildProject(
    afterTest: {
      govuk.setEnvar("GOVUK_APP_DOMAIN", "test.gov.uk")
      // Run seeds twice to ensure they work with pre-existing data
      govuk.runRakeTask("db:seed")
      govuk.runRakeTask("db:seed")
    }
  )
}
