require 'router_reloader'

if ENV['ROUTER_NODES'].present?
  RouterReloader.set_router_reload_urls_from_string(ENV['ROUTER_NODES'])

elsif ! Rails.env.production?
  RouterReloader.router_reload_urls = ["http://localhost:3055/reload"]

else
  raise "No router nodes provided.  Need to set the ROUTER_NODES env variable"

end

if Rails.env.development?
  # In development we want to attempt to reload the router, but not
  # fail if the router isn't running.
  RouterReloader.swallow_connection_errors = true
end
