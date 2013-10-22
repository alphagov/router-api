require 'spec_helper'

describe "managing backends" do
  before :each do
    setup_router_reload_http_stub
  end

  describe "getting details of a backend" do
    it "should return the backend details as JSON" do
      FactoryGirl.create(:backend, :backend_id => "foo", :backend_url => "http://foo.example.com/")

      get "/backends/foo"

      expect(response).to be_success
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
      })
    end

    it "should 404 for a non-existent backend" do
      get "/backends/non-existent"
      expect(response).to be_missing
    end

    after :each do
      expect(router_reload_http_stub).not_to have_been_requested
    end
  end

  describe "creating a backend" do
    it "should create a new backend" do
      put_json "/backends/foo", :backend => {:backend_url => "http://foo.example.com/"}

      expect(response.code.to_i).to eq(201)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
      })

      backend = Backend.find_by_backend_id("foo")
      expect(backend).to be
      expect(backend.backend_url).to eq("http://foo.example.com/")

      # No point reloading for a new backend as it won't have any routes yet.
      expect(router_reload_http_stub).not_to have_been_requested
    end

    it "should return an error if given invalid data" do
      put_json "/backends/foo", :backend => {:backend_url => ""}

      expect(response.code.to_i).to eq(400)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "",
        "errors" => {
          "backend_url" => ["is not a valid HTTP URL"],
        }
      })

      backend = Backend.find_by_backend_id("foo")
      expect(backend).to be_nil

      expect(router_reload_http_stub).not_to have_been_requested
    end

    it "should 404 for a backend_id that doesn't look like a slug" do
      put_json "/backends/foo+bar", :backend => {:backend_url => "http://foo.example.com/"}
      expect(response.code.to_i).to eq(404)

      expect(router_reload_http_stub).not_to have_been_requested
    end
  end

  describe "updating a backend" do
    it "should update the backend" do
      backend = FactoryGirl.create(:backend, :backend_id => "foo", :backend_url => "http://something.example.com/")
      put_json "/backends/foo", :backend => {:backend_url => "http://something-else.example.com/"}

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://something-else.example.com/",
      })

      backend.reload
      expect(backend.backend_url).to eq("http://something-else.example.com/")

      expect(router_reload_http_stub).to have_been_requested
    end

    it "should return an error if given invalid data" do
      backend = FactoryGirl.create(:backend, :backend_id => "foo", :backend_url => "http://something.example.com/")
      put_json "/backends/foo", :backend => {:backend_url => ""}

      expect(response.code.to_i).to eq(400)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "",
        "errors" => {
          "backend_url" => ["is not a valid HTTP URL"],
        }
      })

      backend.reload
      expect(backend.backend_url).to eq("http://something.example.com/")

      expect(router_reload_http_stub).not_to have_been_requested
    end
  end

  describe "deleting a backend" do
    before :each do
      @backend = FactoryGirl.create(:backend, :backend_id => "foo", :backend_url => "http://foo.example.com/")
    end

    it "should delete the backend" do
      delete "/backends/foo"

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
      })

      backend = Backend.find_by_backend_id("foo")
      expect(backend).not_to be

      # No point reloading for a deleted backend as it can't have had any routes
      expect(router_reload_http_stub).not_to have_been_requested
    end

    it "should not allow deletion of a backend with associated routes" do
      FactoryGirl.create(:backend_route, :backend_id => @backend.backend_id)

      delete "/backends/foo"

      expect(response.code.to_i).to eq(400)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
        "errors" => {
          "base" => ["Backend has routes - can't delete"],
        },
      })

      backend = Backend.find_by_backend_id("foo")
      expect(backend).to be

      expect(router_reload_http_stub).not_to have_been_requested
    end

    it "should 404 for a non-existent backend" do
      delete "/backends/non-existent"
      expect(response.code.to_i).to eq(404)

      expect(router_reload_http_stub).not_to have_been_requested
    end
  end
end
