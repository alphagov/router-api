#!/usr/bin/env groovy

library("govuk")

REPOSITORY = "router-api"

repoName = JOB_NAME.split('/')[0]

node ("mongodb-2.4") {
  govuk.buildProject(
    publishingE2ETests: true,
    brakeman: true,
    afterTest: {
      govuk.setEnvar("GOVUK_APP_DOMAIN", "test.gov.uk")
      // Run seeds twice to ensure they work with pre-existing data
      govuk.runRakeTask("db:seed")
      govuk.runRakeTask("db:seed")
    }
  )
}
