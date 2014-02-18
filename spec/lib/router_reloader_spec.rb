require 'spec_helper'
require 'router_reloader'

describe RouterReloader do

  describe "triggering a reload of routes" do
    before :each do
      RouterReloader.stub(:router_reload_urls).and_return(["http://foo.example.com:1234/reload", "http://bar.example.com:4321/reload"])
    end

    context "when route reloading is enabled" do
      before :each do
        @old_env, ENV['ENABLE_ROUTER_RELOADING'] = ENV['ENABLE_ROUTER_RELOADING'], '1'
      end
      after :each do
        ENV['ENABLE_ROUTER_RELOADING'] = @old_env
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
      end
    end

    context "when router reloading is not enabled" do
      before :each do
        @old_env, ENV['ENABLE_ROUTER_RELOADING'] = ENV['ENABLE_ROUTER_RELOADING'], nil
      end
      after :each do
        ENV['ENABLE_ROUTER_RELOADING'] = @old_env
      end

      it "should not attempt to trigger a reload, and return true" do
        r1 = stub_request(:post, "http://foo.example.com:1234/reload").to_return(:status => 200)
        r2 = stub_request(:post, "http://bar.example.com:4321/reload").to_return(:status => 200)

        expect(RouterReloader.reload).to be_true

        expect(r1).not_to have_been_requested
        expect(r2).not_to have_been_requested
      end
    end
  end
end
