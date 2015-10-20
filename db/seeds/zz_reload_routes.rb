require 'router_reloader'

# The router isn't running when this is called on the CI box.
RouterReloader.swallow_connection_errors = true unless Rails.env.production?
RouterReloader.reload
