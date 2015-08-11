######################################
#
# This file is run on every deploy.
# Ensure any changes account for this.
#
######################################

require "gds_api/publishing_api/special_route_publisher"
require "securerandom"

routes = [
  {
    content_id: "a652fcab-7aa6-42e5-9d72-c82d7e3c5377",
    base_path: "/apply-for-a-licence",
    type: "prefix",
    rendering_app: "licensify",
    title: "Apply for a licence",
    description: "Redirects to the licence finder."
  },
  {
    content_id: "81e8949b-a3fa-4712-97ff-decdd80024c8",
    base_path: "/trade-tariff",
    type: "prefix",
    rendering_app: "tariff",
    publishing_app: "tariff",
    title: "Trade tariff finder",
    description: "Landing page for the trade tariff finder."
  },
  {
    content_id: "e055ca55-d6d7-4815-977d-2a022b93090f",
    base_path: "/__canary__",
    type: "exact",
    rendering_app: "canary-frontend",
    title: "Canary endpoint",
    description: "Provides an endpoint to check against when testing our routing from start to finish."
  },
]

publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new
routes.each do |route|
  route = {
    publishing_app: "router-api"
  }.merge(route)

  publisher.publish(route)
end
