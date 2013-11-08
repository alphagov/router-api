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
  route = Route.find_or_initialize_by_incoming_path_and_route_type(from, 'exact')
  route.handler = 'redirect'
  route.redirect_to = to
  route.redirect_type = 'temporary'
  route.save :validate => false
end
