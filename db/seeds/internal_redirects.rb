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
  route = Route.find_or_initialize_by(incoming_path: from, route_type: 'exact')
  route.handler = 'redirect'
  route.redirect_to = to
  route.redirect_type = 'permanent'
  route.save!
end
