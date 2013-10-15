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
  'businesssupportfinder',
  'calculators',
  'calendars',
  'canary-frontend',
  'datainsight-frontend',
  'designprinciples',
  'feedback',
  'frontend',
  'licencefinder',
  'licensify',
  'limelight',
  'publicapi',
  'search',
  'smartanswers',
  'static',
  'tariff',
  'transaction-wrappers',
  'transactions-explorer',
  'whitehall-frontend',
]

backends.each do |backend|
  url = "http://#{backend}.#{ENV['GOVUK_APP_DOMAIN']}/"
  puts "Backend #{backend} => #{url}"
  be = Backend.find_or_initialize_by_backend_id(backend)
  be.backend_url = url
  be.save!
end

routes = [
  %w(/ prefix frontend),

  %w(/autocomplete exact search),
  %w(/preload-autocomplete exact search),
  %w(/sitemap.xml exact search),
  # TODO: Fix the sitemap routes.
  #} else if (req.url ~ "^/autocomplete(\?.*)?$|^/preload-autocomplete(\?.*)?$|^/sitemap[^/]*.xml(\?.*)?$") {
  %w(/sitemap prefix search),

  %w(/bank-holidays prefix calendars),
  %w(/bank-holidays.json prefix calendars),
  %w(/gwyliau-banc prefix calendars),
  %w(/gwyliau-banc.json prefix calendars),
  %w(/when-do-the-clocks-change prefix calendars),
  %w(/when-do-the-clocks-change.json prefix calendars),

  %w(/child-benefit-tax-calculator prefix calculators),

  %w(/favicon.ico exact static),
  %w(/humans.txt exact static),
  %w(/robots.txt exact static),
  %w(/fonts prefix static),
  %w(/google991dec8b62e37cfb.html exact static),
  %w(/apple-touch-icon.png exact static),
  %w(/apple-touch-icon-144x144.png exact static),
  %w(/apple-touch-icon-114x114.png exact static),
  %w(/apple-touch-icon-72x72.png exact static),
  %w(/apple-touch-icon-57x57.png exact static),
  %w(/apple-touch-icon-precomposed.png exact static),

  %w(/designprinciples prefix designprinciples),
  %w(/service-manual prefix designprinciples),
  %w(/transformation prefix designprinciples),

  %w(/licence-finder prefix licencefinder),

  %w(/business-finder-support-finder prefix businesssupportfinder),

  %w(/apply-for-a-licence prefix licensify),

  %w(/trade-tariff prefix tariff),

  %w(/api prefix publicapi),

  %w(/feedback prefix feedback),

  # TODO: replace foo with real values
  %w(/performance/foo/api prefix publicapi),
  %w(/performance exact datainsight-frontend),
  %w(/performance/dashboard prefix datainsight-frontend),
  %w(/performance/transactions-explorer prefix transactions-explorer),
  %w(/performance prefix limelight),

  %w(/government prefix whitehall-frontend),

  %w(/__canary__ exact canary-frontend),

  %w(/pay-foreign-marriage-certificates prefix transaction-wrappers),
  %w(/pay-foreign-marriage-certificates exact frontend),
  %w(/pay-foreign-marriage-certificates.json exact frontend),
  %w(/deposit-foreign-marriage prefix transaction-wrappers),
  %w(/deposit-foreign-marriage exact frontend),
  %w(/deposit-foreign-marriage.json exact frontend),
  %w(/pay-register-death-abroad prefix transaction-wrappers),
  %w(/pay-register-death-abroad exact frontend),
  %w(/pay-register-death-abroad.json exact frontend),
  %w(/pay-register-birth-abroad prefix transaction-wrappers),
  %w(/pay-register-birth-abroad exact frontend),
  %w(/pay-register-birth-abroad.json exact frontend),
  %w(/pay-legalisation-post prefix transaction-wrappers),
  %w(/pay-legalisation-post exact frontend),
  %w(/pay-legalisation-post.json exact frontend),
  %w(/pay-legalisation-drop-off prefix transaction-wrappers),
  %w(/pay-legalisation-drop-off exact frontend),
  %w(/pay-legalisation-drop-off.json exact frontend),
]

smartanswers = [
  'additional-commodity-code',
  'am-i-getting-minimum-wage',
  'apply-for-probate',
  'auto-enrolled-into-workplace-pension',
  'become-a-driving-instructor',
  'become-a-motorcycle-instructor',
  'benefits-if-you-are-abroad',
  'calculate-agricultural-holiday-entitlement',
  'calculate-employee-redundancy-pay',
  'calculate-married-couples-allowance',
  'calculate-night-work-hours',
  'calculate-state-pension',
  'calculate-statutory-sick-pay',
  'calculate-your-child-maintenance',
  'calculate-your-holiday-entitlement',
  'calculate-your-maternity-pay',
  'calculate-your-redundancy-pay',
  'can-i-get-a-british-passport',
  'childcare-costs-for-tax-credits',
  'claim-a-national-insurance-refund',
  'energy-grants-calculator',
  'estimate-self-assessment-penalties',
  'exchange-a-foreign-driving-licence',
  'find-a-british-embassy',
  'help-if-you-are-arrested-abroad',
  'inherits-someone-dies-without-will',
  'legal-right-to-work-in-the-uk',
  'legalisation-document-checker',
  'marriage-abroad',
  'maternity-paternity-calculator',
  'minimum-wage-calculator-employers',
  'non-gb-driving-licence',
  'overseas-passports',
  'pip-checker',
  'plan-adoption-leave',
  'plan-maternity-leave',
  'plan-paternity-leave',
  'recognise-a-trade-union',
  'register-a-birth',
  'register-a-death',
  'report-a-lost-or-stolen-passport',
  'request-for-flexible-working',
  'simplified-expenses-checker',
  'student-finance-calculator',
  'student-finance-forms',
  'towing-rules',
  'uk-benefits-abroad',
  'vehicles-you-can-drive',
]
smartanswers.each do |sa|
  routes << [sa, "prefix", "smartanswers"]
  routes << ["#{sa}.json", "exact", "smartanswers"]
end

routes.each do |path, type, backend|
  puts "Route #{path} (#{type}) => #{backend}"
  abort "Invalid backend #{backend}" unless Backend.find_by_backend_id(backend)
  route = Route.find_or_initialize_by_incoming_path_and_route_type(path, type)
  route.backend_id = backend
  route.save!
end
