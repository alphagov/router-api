require "route_dumper"

namespace :routes do
  desc "Reload routes in Router"
  task reload: :environment do
    puts "Reloading router"

    RouterReloader.reload
  end

  desc "Dump routes"
  task :dump, [:filename] => [:environment] do |_, args|
    raise "Missing filename." unless args[:filename]

    RouteDumper.new(args[:filename]).dump
  end

  desc "TEMP - Remove Whitehall Frontend routes"
  task remove_whitehall_frontend_routes: :environment do
    Route.where(handler: "backend", backend_id: "whitehall-frontend").delete_all
  end
end
