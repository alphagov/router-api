require 'spec_helper'
require 'router_reloader'

describe RouterReloader do

  describe "triggering a reload of routes" do
    before :each do
      RouterReloader.stub(:router_reload_urls).and_return(["http://foo.example.com:1234/reload", "http://bar.example.com:4321/reload"])
    end

    it "should POST to the reload endpoint on all the configured routers, and return true" do
      r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(:status => 200)
      r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(:status => 200)

      expect(RouterReloader.reload).to be_true

      expect(r1).to have_been_requested.once
      expect(r2).to have_been_requested.once
    end

    context "error handling" do
      it "should send an exception notification, and return false on HTTP errors" do
        r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(:status => 401, :body => "Authorisation required")
        r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(:status => 404, :body => "Not found")

        expect(Airbrake).to receive(:notify_or_ignore) {|ex, options|
          expect(ex.message).to eq("Failed to trigger reload on some routers")
          errors = options[:parameters][:errors]
          expect(errors[0]).to eq({:url => "http://foo.example.com:1234/reload", :status => "401", :body => "Authorisation required"})
          expect(errors[1]).to eq({:url => "http://bar.example.com:4321/reload", :status => "404", :body => "Not found"})
        }
        expect(RouterReloader.reload).to be_false
      end

      it "should still reload subsequent hosts on error" do
        r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(:status => 401, :body => "Authorisation required")
        r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(:status => 200)

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
        RouterReloader.stub(:swallow_connection_errors).and_return(true)
        stub_request(:post, "http://foo.example.com:1234/reload").to_raise(Errno::ECONNREFUSED)

        expect(RouterReloader.reload).to eq(true)
      end
    end
  end
end
