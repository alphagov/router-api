namespace :routes do
  desc "Reload routes in Router"
  task reload: :environment do
    puts "Reloading router"

    RouterReloader.reload
  end
end
