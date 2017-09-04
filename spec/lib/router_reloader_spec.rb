require 'rails_helper'
require 'router_reloader'

RSpec.describe RouterReloader do
  describe "parsing router reload urls from env var string" do
    around :each do |example|
      original_urls = RouterReloader.router_reload_urls
      example.run
      RouterReloader.router_reload_urls = original_urls
    end

    it "should generate urls from list of host:port pairs" do
      RouterReloader.set_router_reload_urls_from_string("foo.bar:1234,bar.baz:2345")

      expect(RouterReloader.router_reload_urls).to eq([
        "http://foo.bar:1234/reload",
        "http://bar.baz:2345/reload",
      ])
    end

    it "should cope with extra whitespace in the string" do
      RouterReloader.set_router_reload_urls_from_string(" foo.bar:1234, bar.baz:2345 \n")

      expect(RouterReloader.router_reload_urls).to eq([
        "http://foo.bar:1234/reload",
        "http://bar.baz:2345/reload",
      ])
    end
  end

  describe "parsing router reload urls from env var file" do
    around :each do |example|
      original_urls = RouterReloader.router_reload_urls
      example.run
      RouterReloader.router_reload_urls = original_urls
    end

    it "should generate urls from list of host:port pairs" do
      filename = 'spec/support/router_nodes.txt'

      RouterReloader.set_router_reload_urls_from_file(filename)

      expect(RouterReloader.router_reload_urls).to eq([
        "http://foo.bar:1234/reload",
        "http://bar.baz:2345/reload",
      ])
    end
  end

  describe "triggering a reload of routes" do
    before :each do
      allow(RouterReloader).to receive(:router_reload_urls).and_return(["http://foo.example.com:1234/reload", "http://bar.example.com:4321/reload"])
    end

    it "should POST to the reload endpoint on all the configured routers, and return true" do
      r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(status: 200)
      r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(status: 202)

      expect(RouterReloader.reload).to be_truthy

      expect(r1).to have_been_requested.once
      expect(r2).to have_been_requested.once
    end

    context "error handling" do
      it "should send an exception notification, and return false on HTTP errors" do
        r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(status: 401, body: "Authorisation required")
        r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(status: 404, body: "Not found")

        expect(GovukError).to receive(:notify) {|message, options|
          expect(message).to eq("Failed to trigger reload on some routers")
          errors = options[:extra][:errors]
          expect(errors[0]).to eq({url: "http://foo.example.com:1234/reload", status: "401", body: "Authorisation required"})
          expect(errors[1]).to eq({url: "http://bar.example.com:4321/reload", status: "404", body: "Not found"})
        }
        expect(RouterReloader.reload).to be_falsey
      end

      it "should still reload subsequent hosts on error" do
        r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(status: 401, body: "Authorisation required")
        r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(status: 202)

        RouterReloader.reload

        expect(r2).to have_been_requested.once
      end

      it "should pass through any exceptions raised" do
        stub_request(:post, "http://foo.example.com:1234/reload").to_raise(Errno::ECONNREFUSED)

        expect {
          RouterReloader.reload
        }.to raise_error(Errno::ECONNREFUSED)
      end

      it "should swallow connection refused errors when configured to" do
        allow(RouterReloader).to receive(:swallow_connection_errors).and_return(true)
        stub_request(:post, "http://foo.example.com:1234/reload").to_raise(Errno::ECONNREFUSED)

        expect(RouterReloader.reload).to eq(true)
      end
    end
  end
end
