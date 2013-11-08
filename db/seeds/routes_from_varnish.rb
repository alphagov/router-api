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
  'datainsight-frontend',
  'frontend',
  'licensify',
  'limelight',
  'publicapi',
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

  %w(/performance/deposit-foreign-marriage/api prefix publicapi),
  %w(/performance/vehicle-licensing/api prefix publicapi),
  %w(/performance/government/api prefix publicapi),
  %w(/performance/hmrc_preview/api prefix publicapi),
  %w(/performance/licence_finder/api prefix publicapi),
  %w(/performance/licensing/api prefix publicapi),
  %w(/performance/land-registry/api prefix publicapi),
  %w(/performance/lasting-power-of-attorney/api prefix publicapi),
  %w(/performance/pay-foreign-marriage-certificates/api prefix publicapi),
  %w(/performance/pay-legalisation-drop-off/api prefix publicapi),
  %w(/performance/pay-legalisation-post/api prefix publicapi),
  %w(/performance/pay-register-birth-abroad/api prefix publicapi),
  %w(/performance/pay-register-death-abroad/api prefix publicapi),
  %w(/performance/sorn/api prefix publicapi),
  %w(/performance/tax-disc/api prefix publicapi),
  %w(/performance/test/api prefix publicapi),

  %w(/performance/dashboard prefix datainsight-frontend),
  %w(/performance/transactions-explorer prefix transactions-explorer),
  %w(/performance prefix limelight),

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

# Remove some previously seeded routes.
# This can be removed once it's run on prod.
[
  %w(/ prefix),
].each do |path, type|
  if route = Route.where(:incoming_path => path, :route_type => type).first
    puts "Removing route #{path} (#{type}) => #{route.backend_id}"
    route.destroy
  end
end
