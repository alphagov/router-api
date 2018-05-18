require "net/http"

class RouterReloader
  def self.reload
    new.reload
  end

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
    errors = post_reload_urls.compact
    return true if errors.empty?

    GovukError.notify(
      "Failed to trigger reload on some routers",
      extra: {
        errors: errors.map do |url, resp|
          { url: url, status: resp.code, body: resp.body }
        end
      }
    )

    false
  end

private

  def swallow_connection_errors?
    Rails.env.test? || Rails.env.development?
  end

  def post_reload_urls
    urls.map do |url|
      response = Net::HTTP.post_form(URI.parse(url), {})
      [url, response] unless response.code.to_s.match?(/20[02]/)
    end
  rescue Errno::ECONNREFUSED
    raise unless swallow_connection_errors?
    []
  end

  def urls_from_nodes(nodes)
    nodes.map { |node| "http://#{node}/reload" }
  end

  def urls_from_string(string)
    urls_from_nodes(string.split(",").map(&:strip))
  end

  def urls_from_file(filename)
    urls_from_nodes(File.readlines(filename).map(&:chomp))
  end
end
