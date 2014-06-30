require 'router_reloader'

# The router isn't running when this is called on the CI box.
unless Rails.env.production?
  RouterReloader.swallow_connection_errors = true
end
RouterReloader.reload
