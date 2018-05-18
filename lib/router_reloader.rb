require "net/http"

class RouterReloader
  def self.reload
    new.reload
  end

  # To be set in dev mode so that this can run when the router isn't running.
  cattr_accessor :swallow_connection_errors

  def urls
    @urls ||= begin
      if ENV["ROUTER_NODES"].present?
        urls_from_string(ENV["ROUTER_NODES"])
      elsif ENV["ROUTER_NODES_FILE"].present?
        urls_from_file(ENV["ROUTER_NODES_FILE"])
      elsif !Rails.env.production?
        ["http://localhost:3055/reload"]
      else
        raise "No router nodes provided. Need to set the ROUTER_NODES env variable"
      end
    end
  end

  def reload
    @errors = []
    urls.each do |url|
      response = Net::HTTP.post_form(URI.parse(url), {})
      @errors << [url, response] unless response.code.to_s.match?(/20[02]/)
    end
    if @errors.any?
      GovukError.notify(
        "Failed to trigger reload on some routers",
        extra: { errors: @errors.map { |url, resp| { url: url, status: resp.code, body: resp.body } } }
      )
      return false
    end
    true
  rescue Errno::ECONNREFUSED
    raise unless self.class.swallow_connection_errors
    true
  end

  private

  def urls_from_string(string)
    nodes = string.split(",").map(&:strip)
    nodes.map { |node| "http://#{node}/reload" }
  end

  def urls_from_file(filename)
    nodes = File.readlines(filename).map(&:chomp)
    nodes.map { |node| "http://#{node}/reload" }
  end
end
