class FixOldSpecialistPublisherRoutes < Mongoid::Migration
  def self.up
    Route.where(backend_id: "specialist-frontend").each do |route|
      route.backend_id = "government-frontend"
      route.save!
    end

    if RouterReloader.reload
      puts "Router reloaded"
    else
      puts "Failed to reload router"
    end
  end

  def self.down
  end
end
