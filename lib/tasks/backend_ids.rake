namespace :backend_ids do
  task fix: :environment do
    affected_base_paths = %w(
      /government/statistics/announcements/farming-statistics-provisional-crop-areas-yields-and-livestock-populations-at-1-june-2019-uk
    )

    affected_base_paths.each do |base_path|
      route = Route.find_by(incoming_path: base_path)
      if route.backend_id == "whitehall-frontend"
        puts "updating #{base_path}"
        route.update_attributes(backend_id: "government-frontend")
      else
        puts "skipping #{base_path}"
      end
    end

    RouterReloader.reload
  end
end
