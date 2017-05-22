#!/usr/bin/env groovy

REPOSITORY = "router-api"

repoName = JOB_NAME.split('/')[0]

node ("mongodb-2.4") {
  def govuk = load "/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy"

  try {
    stage("Checkout") {
      checkout scm
    }

    stage("Build") {
      sh "${WORKSPACE}/jenkins.sh"
    }

    stage("Push release tag") {
      govuk.pushTag(REPOSITORY, env.BRANCH_NAME, "release_" + env.BUILD_NUMBER)
    }

    if (govuk.hasDockerfile()) {
      stage("Build Docker image") {
        govuk.buildDockerImage(repoName, env.BRANCH_NAME)
      }

      stage("Push Docker image") {
        govuk.pushDockerImage(repoName, env.BRANCH_NAME)
      }

      if (env.BRANCH_NAME == "master") {
        stage("Tag Docker image") {
          dockerTag = "release_${env.BUILD_NUMBER}"
          govuk.pushDockerImage(repoName, env.BRANCH_NAME, dockerTag)
        }
      }
    }

    stage("Deploy on Integration") {
      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, "release", "deploy")
    }
  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: "Mailer",
          notifyEveryUnstableBuild: true,
          recipients: "govuk-ci-notifications@digital.cabinet-office.gov.uk",
          sendToIndividuals: true])
    throw e
  }
}
