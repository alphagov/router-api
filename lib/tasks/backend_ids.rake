namespace :backend_ids do
  task fix: :environment do
    affected_base_paths = %w(
      /government/statistics/labour-market-statistics-may-2015
      /government/statistics/equality-statistics-for-the-northern-ireland-civil-service-1-jan-2017
      /government/statistics/personnel-statistics-for-the-nics-based-on-staff-in-post-at-1-april-2017
      /government/statistics/announcements/animal-feed-production-for-great-britain-august-2016
      /government/statistics/announcements/vocational-and-other-qualifications-quarterly-january-to-march-2017
      /government/statistics/announcements/weekly-all-cause-mortality-surveillance-weeks-ending-6-august-2017-and-13-august-2017
      /government/publications/information-on-plans-for-payment-by-results-in-2013-to-2014
    )

    affected_base_paths.each do |base_path|
      route = Route.find_by(incoming_path: base_path)
      if route.backend_id == "whitehall-frontend"
        puts "updating #{base_path}"
        route.update(backend_id: "government-frontend")
      else
        puts "skipping #{base_path}"
      end
    end

    RouterReloader.reload
  end
end
