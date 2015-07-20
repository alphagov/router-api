######################################
#
# This file is run on every deploy.
# Ensure any changes account for this.
#
######################################

unless ENV['GOVUK_APP_DOMAIN'].present?
  abort "GOVUK_APP_DOMAIN is not set.  Maybe you need to run under govuk_setenv..."
end

backends = [
  'canary-frontend',
  'licensify',
  'tariff',
  'transactions-explorer',
]

backends.each do |backend|
  url = "http://#{backend}.#{ENV['GOVUK_APP_DOMAIN']}/"
  puts "Backend #{backend} => #{url}"
  be = Backend.find_or_initialize_by(:backend_id => backend)
  be.backend_url = url
  be.save!
end

routes = [
  %w(/apply-for-a-licence prefix licensify),

  %w(/trade-tariff prefix tariff),

  %w(/performance/transactions-explorer prefix transactions-explorer),

  %w(/__canary__ exact canary-frontend),
]

routes.each do |path, type, backend|
  puts "Route #{path} (#{type}) => #{backend}"
  abort "Invalid backend #{backend}" unless Backend.where(:backend_id => backend).any?
  route = Route.find_or_initialize_by(:incoming_path => path, :route_type => type)
  route.handler = "backend"
  route.backend_id = backend
  route.save!
end
