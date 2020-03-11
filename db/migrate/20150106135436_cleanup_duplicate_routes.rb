class CleanupDuplicateRoutes < Mongoid::Migration
  def self.up
    duplicate_routes.each do |prefix, exact|
      if matching_route?(prefix, exact)
        puts "deleting #{route_summary(exact)}, keeping #{route_summary(prefix)}"
        exact.destroy
      else
        if prefix.handler == "gone"
          puts "deleting #{route_summary(prefix)}, keeping #{route_summary(exact)}"
          prefix.destroy
        elsif EXACT_ROUTES_TO_KEEP.include?(prefix.incoming_path)
          puts "deleting #{route_summary(prefix)}, keeping #{route_summary(exact)}"
          prefix.destroy
        else
          raise "Unexpected duplicate found - #{route_summary(prefix)} and #{route_summary(exact)}"
        end
      end
    end
  end

  def self.down; end

  def self.route_summary(route)
    str = "#{route.route_type}:#{route.incoming_path}(#{route.handler}"
    case route.handler
    when "backend"
      str << ":#{route.backend_id}"
    when "redirect"
      str << ":#{route.redirect_to}"
    end
    str << ")"
    str
  end

  def self.duplicate_routes
    duplicates = []
    Route.prefix.asc(:incoming_path).each do |prefix|
      exact = Route.where(incoming_path: prefix.incoming_path, route_type: "exact").first
      next unless exact

      duplicates << [prefix, exact]
    end
    duplicates
  end

  def self.matching_route?(a, b)
    return false unless a.handler == b.handler

    case a.handler
    when "backend"
      a.backend_id == b.backend_id
    when "redirect"
      a.redirect_to == b.redirect_to &&
        a.redirect_type == b.redirect_type
    else
      true
    end
  end

  EXACT_ROUTES_TO_KEEP = %w(
    /annual-accounting-scheme
    /apply-building-regulation-approval-from-council
    /apply-for-fuel-relief
    /apply-hgv-vehicle-licence-tax-disc-form-v85
    /apply-special-educational-needs-assessment
    /arts-business-cymru-investment-programmes-2012-13-culturestep
    /benefits-adviser
    /business-expansion-support-orkney
    /business-finance-for-you
    /business-growth-grant
    /business-programme-princes-charities-young-people-burnley
    /business-support-grant-wales
    /car-tax-disc-vehicle-licence-using-form-v10
    /carbon-trust-programme-northern-ireland
    /check-an-employees-right-to-work-documents
    /childcare-premises-registration-england
    /childrens-services
    /claiming-driving-test-pass
    /coal-mining-and-exploration-licence
    /commercial-fishing-fisheries/monitoring-enforcement
    /commercial-fishing-fisheries/regulations-restrictions
    /companies-house
    /competition
    /competition/business-law-compliance
    /competition/ca98-civil-cartels
    /competition/competition-law-compliance
    /competition/consumer-law-enforcement
    /competition/consumer-protection-regulations
    /competition/criminal-cartels
    /competition/reviews-orders-undertakings
    /competition/unfair-terms-regulations-compliance
    /complain-about-the-insolvency-service
    /complain-green-deal-eco
    /csachanges
    /denatured-alcohol-production-distribution
    /deposit-foreign-marriage
    /done/book-practical-driving-test
    /dsa-driving-test-booking-service-data-protection
    /dsa-practical-test-booking-data-protection
    /dsa-special-tests-for-instructors
    /dsa-taxi-driving-test
    /east-scotland-investment-fund-angus
    /enterprise-europe-network
    /environmental-management
    /export-communications-review
    /export-marketing-research-scheme
    /feedback
    /flat-rate-scheme-small-businesses
    /health-protection/migrant-health
    /immigration-operational-guidance
    /innovateuk
    /international-child-abduction
    /ips-regional-passport-office
    /keep-or-release-non-native-fish-england-and-wales
    /lanarkshire-business-consultancy-support-south-lanarkshire
    /live-fish-shellfish-importer-authorisation
    /manufacture-authorisation-veterinary-medicines
    /marketing-authorisation-of-veterinary-medicines
    /ni-start-up-advice-east
    /ohsbas-business-loan
    /ohsbas-micro-business-grant
    /oil-and-gas
    /one-stop-services
    /overseas-market-introduction-service
    /p800-what-to-do
    /packaging-waste-producer-supplier-responsibilities
    /pay-foreign-marriage-certificates
    /pay-legalisation-drop-off
    /pay-legalisation-post
    /pay-register-birth-abroad
    /pay-register-death-abroad
    /paye/annual-tasks
    /paye/business-changes
    /paye/employees
    /paye/expenses-benefits
    /paye/introduction
    /paye/news-updates
    /paye/registering-getting-started
    /paye/regular-tasks
    /paye/special-types-employee-pay
    /paye/statutory-leave-pay
    /payslips-your-rights
    /performance/dashboard
    /pollution-inventory-reporting-england-and-wales
    /psybt-outer-hebrides
    /recognise-a-trade-union
    /register-as-childminder-england
    /register-as-early-years-childminder-children-under-5-england
    /registration-with-the-financial-services-authority
    /renewable-heat-incentive-for-homeowners
    /report-debris-motorways-main-roads
    /report-pet-medicine-problem
    /reporting-road-obstruction
    /research-and-development-r-d-grants
    /running-charity
    /sab-low-interest-loans-aberdeenshire
    /schools-colleges
    /slaughterman-licence-england-wales-scotland
    /start-your-business-newport-and-gwent
    /tourism-financial-assistance-shetland-islands
    /tourism-support-grant-west-dunbartonshire
    /tradeshow-access-programme
    /travel-grants-medical-dental-students-england
    /uk-border-agency
    /uk-export-finance
    /vat
    /vat-consumers
    /vat-online-services-helpdesk
    /vehicle-exempt-from-car-tax
    /waste-packaging-reprocessor-accreditation-england-wales-scotland
    /west-scotland-loan-fund-wslf-helensburgh-lomond
    /wine-producer-s-licence
    /young-person-wage-incentives
  ).freeze
end
