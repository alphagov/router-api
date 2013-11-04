require 'router_reloader'

module RouterReloadStubs
  def setup_router_reload_http_stub
    # Assume it's only configured with a single URL in development/test
    @router_reload_http_stub = WebMock.stub_request(:post, RouterReloader.router_reload_urls.first)

    old_env, ENV['ENABLE_ROUTER_RELOADING'] = ENV['ENABLE_ROUTER_RELOADING'], '1'
    example.example_group.after :each do
      ENV['ENABLE_ROUTER_RELOADING'] = old_env
    end
  end

  def stub_router_reload_error
    WebMock.stub_request(:post, RouterReloader.router_reload_urls.first).
      to_return(:status => 500, :body => "Error")
  end

  def router_reload_http_stub
    @router_reload_http_stub
  end
end

RSpec.configuration.include RouterReloadStubs, :type => :request
