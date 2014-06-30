require 'router_reloader'
if Rails.env.development?
  # In development we want to attempt to reload the router, but not
  # fail if the router isn't running.
  RouterReloader.swallow_connection_errors = true
end
