######################################
#
# This file is run on every deploy.
# Ensure any changes account for this.
# XXX: This will be overwritten on deploy!
#
######################################

external_redirects = [
  # %w(/foo http://www.example.com/),
]
external_redirects.each do |from, to|
  puts "Adding redirect from #{from} (exact) -> #{to}"
  route = Route.find_or_initialize_by(incoming_path: from, route_type: 'exact')
  route.handler = 'redirect'
  route.redirect_to = to
  route.redirect_type = 'temporary'
  route.save!
end
