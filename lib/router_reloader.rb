require 'net/http'

class RouterReloader
  def self.reload
    new(router_urls).reload
  end

  def self.router_urls
    @router_urls ||= YAML.load_file(Rails.root.join("config", "router_urls.yml"))
  end

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
      ExceptionNotifier.notify_exception(
        RuntimeError.new("Failed to trigger reload on some routers"),
        :data => { :errors => @errors.map {|url, resp| {:url => url, :status => resp.code, :body => resp.body} } }
      )
    end
  end
end
