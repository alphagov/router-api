######################################
#
# This file is run on every deploy.
# Ensure any changes account for this.
# XXX: This will be overwritten on deploy!
#
######################################

unless ENV['GOVUK_APP_DOMAIN'].present?
  abort "GOVUK_APP_DOMAIN is not set.  Maybe you need to run under govuk_setenv..."
end

internal_redirects_case_insensitive = [
]

internal_redirects = [
]

[internal_redirects_case_insensitive, internal_redirects].each do |redirects|
  redirects.each do |from, to|
    puts "Adding redirect #{from} -> #{to}"
    route = Route.find_or_initialize_by_incoming_path_and_route_type(from, 'exact')
    route.handler = 'redirect'
    route.redirect_to = to
    route.redirect_type = 'permanent'
    route.save!
  end
end

require 'router_reloader'
RouterReloader.reload
