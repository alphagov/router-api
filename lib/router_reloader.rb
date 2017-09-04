require 'net/http'

class RouterReloader
  def self.reload
    new(router_reload_urls).reload
  end

  # set from an initializer
  cattr_accessor :router_reload_urls
  def self.set_router_reload_urls_from_string(router_nodes_str)
    nodes = router_nodes_str.split(',').map(&:strip)
    self.router_reload_urls = nodes.map {|node| "http://#{node}/reload" }
  end

  # To be set in dev mode so that this can run when the router isn't running.
  cattr_accessor :swallow_connection_errors

  def initialize(urls)
    @urls = urls
  end

  def reload
    @errors = []
    @urls.each do |url|
      response = Net::HTTP.post_form(URI.parse(url), {})
      @errors << [url, response] unless response.code.to_s =~ /20[02]/
    end
    if @errors.any?
      GovukError.notify(
        "Failed to trigger reload on some routers",
        extra: { errors: @errors.map {|url, resp| {url: url, status: resp.code, body: resp.body} } }
      )
      return false
    end
    true
  rescue Errno::ECONNREFUSED
    raise unless self.class.swallow_connection_errors
    true
  end
end
