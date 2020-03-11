class UpdateTravelAdviceBackendId < Mongoid::Migration
  def self.up
    Route.where(backend_id: "frontend", incoming_path: /^\/foreign-travel-advice\/[aA-zZ-]+$/).each do |route|
      route.backend_id = "multipage-frontend"
      route.save!
      puts "Updated #{route.incoming_path} to backend_id: multipage-frontend"
    end

    if RouterReloader.reload
      puts "Router reloaded"
    else
      puts "Failed to reload router"
    end
  end

  def self.down; end
end
