class AddEmailUnsubscribePrefixRoute < Mongoid::Migration
  def self.up
    Route.find_or_create_by(
      incoming_path: "/email/unsubscribe",
      route_type: "prefix",
      handler: "backend",
      disabled: false,
      backend_id: "email-alert-frontend",
    )

    if RouterReloader.reload
      puts "Router reloaded"
    else
      puts "Failed to reload router"
    end
  end

  def self.down
  end
end
