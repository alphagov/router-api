require 'net/http'

class RouterReloader
  def self.reload
    new(router_reload_urls).reload
  end

  def self.router_reload_urls
    @router_reload_urls ||= YAML.load_file(Rails.root.join("config", "router_reload_urls.yml"))
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
      @errors << [url, response] unless response.code.to_i == 200
    end
    if @errors.any?
      Airbrake.notify_or_ignore(
        RuntimeError.new("Failed to trigger reload on some routers"),
        :parameters => { :errors => @errors.map {|url, resp| {:url => url, :status => resp.code, :body => resp.body} } }
      )
      return false
    end
    true
  rescue Errno::ECONNREFUSED
    raise unless self.class.swallow_connection_errors
    true
  end
end
