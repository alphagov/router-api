#!/usr/bin/env groovy

REPOSITORY = "router-api"

repoName = JOB_NAME.split('/')[0]

node ("mongodb-2.4") {
  def govuk = load "/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy"
  govuk.buildProject(
    afterTest: {
      govuk.setEnvar("GOVUK_APP_DOMAIN", "test.gov.uk")
      // Run seeds twice to ensure they work with pre-existing data
      govuk.runRakeTask("db:seed")
      govuk.runRakeTask("db:seed")
    }
  )
}
