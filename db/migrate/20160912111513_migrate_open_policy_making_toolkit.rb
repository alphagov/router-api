class MigrateOpenPolicyMakingToolkit < Mongoid::Migration
  def self.up
    update_route_backend("manuals-frontend")
    reload_router
  end

  def self.down
    update_route_backend("whitehall-frontend")
    reload_router
  end

private

  def self.update_route_backend(backend_id)
    incoming_path = "/guidance/open-policy-making-toolkit"

    Route.where(incoming_path: incoming_path).update_all(backend_id: backend_id)

    puts "Updated '#{incoming_path}' to backend_id: '#{backend_id}'"
  end

  def self.reload_router
    if RouterReloader.reload
      puts "Router reloaded"
    else
      puts "Failed to reload router"
    end
  end
end
