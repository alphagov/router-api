require 'rails_helper'
require 'router_reloader'

RSpec.describe RouterReloader do
  describe "parsing router reload urls from env var string" do
    it "should generate urls from list of host:port pairs" do
      ClimateControl.modify ROUTER_NODES: "foo.bar:1234,bar.baz:2345" do
        expect(subject.urls).to eq([
          "http://foo.bar:1234/reload",
          "http://bar.baz:2345/reload",
        ])
      end
    end

    it "should cope with extra whitespace in the string" do
      ClimateControl.modify ROUTER_NODES: "  foo.bar:1234,bar.baz:2345 \n" do
        expect(subject.urls).to eq([
          "http://foo.bar:1234/reload",
          "http://bar.baz:2345/reload",
        ])
      end
    end
  end

  describe "parsing router reload urls from env var file" do
    it "should generate urls from list of host:port pairs" do
      ClimateControl.modify ROUTER_NODES_FILE: "spec/support/router_nodes.txt" do
        expect(subject.urls).to eq([
          "http://foo.bar:1234/reload",
          "http://bar.baz:2345/reload",
        ])
      end
    end
  end

  describe "triggering a reload of routes" do
    before :each do
      allow(subject).to receive(:urls).and_return(
        ["http://foo.example.com:1234/reload", "http://bar.example.com:4321/reload"]
      )
    end

    it "should POST to the reload endpoint on all the configured routers, and return true" do
      r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(status: 200)
      r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(status: 202)

      expect(subject.reload).to be_truthy

      expect(r1).to have_been_requested.once
      expect(r2).to have_been_requested.once
    end

    context "error handling" do
      it "should send an exception notification, and return false on HTTP errors" do
        stub_request(:post, "http://foo.example.com:1234/reload").to_return(status: 401, body: "Authorisation required")
        stub_request(:post, "http://bar.example.com:4321/reload").to_return(status: 404, body: "Not found")

        expect(GovukError).to receive(:notify) { |message, options|
          expect(message).to eq("Failed to trigger reload on some routers")
          errors = options[:extra][:errors]
          expect(errors[0]).to eq(url: "http://foo.example.com:1234/reload", status: "401", body: "Authorisation required")
          expect(errors[1]).to eq(url: "http://bar.example.com:4321/reload", status: "404", body: "Not found")
        }
        expect(subject.reload).to be_falsey
      end

      it "should still reload subsequent hosts on error" do
        stub_request(:post, "http://foo.example.com:1234/reload").to_return(status: 401, body: "Authorisation required")
        r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(status: 202)

        subject.reload

        expect(r2).to have_been_requested.once
      end

      it "should pass through any exceptions raised" do
        stub_request(:post, "http://foo.example.com:1234/reload").to_raise(Errno::ECONNREFUSED)

        expect {
          subject.reload
        }.to raise_error(Errno::ECONNREFUSED)
      end

      it "should swallow connection refused errors when configured to" do
        allow(RouterReloader).to receive(:swallow_connection_errors).and_return(true)
        stub_request(:post, "http://foo.example.com:1234/reload").to_raise(Errno::ECONNREFUSED)

        expect(subject.reload).to eq(true)
      end
    end
  end
end
