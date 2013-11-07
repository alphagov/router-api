######################################
#
# This file is run on every deploy.
# Ensure any changes account for this.
# XXX: This will be overwritten on deploy!
#
######################################

internal_redirects = [
  # %w(/foo /bar),
]
internal_redirects.each do |from, to|
  puts "Adding redirect from #{from} (exact) -> #{to}"
  route = Route.find_or_initialize_by_incoming_path_and_route_type(from, 'exact')
  route.handler = 'redirect'
  route.redirect_to = to
  route.redirect_type = 'permanent'
  route.save!
end

require 'router_reloader'
RouterReloader.reload
