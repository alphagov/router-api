require 'net/http'

class RouterReloader
  ROUTER_RELOAD_PORT = 3055

  def self.reload
    new(router_hosts).reload
  end

  def self.router_hosts
    @router_hosts ||= YAML.load_file(Rails.root.join("config", "router_hosts.yml"))
  end

  def initialize(hosts)
    @hosts = hosts
  end

  def reload
    @errors = []
    @hosts.each do |host|
      url = "http://#{host}:#{ROUTER_RELOAD_PORT}/reload"
      response = Net::HTTP.post_form(URI.parse(url), {})
      @errors << [host, response] unless response.code.to_i == 200
    end
    if @errors.any?
      ExceptionNotifier.notify_exception(
        RuntimeError.new("Failed to trigger reload on some routers"),
        :data => { :errors => @errors.map {|host, resp| {:host => host, :status => resp.code, :body => resp.body} } }
      )
    end
  end
end
