require 'rails_helper'

RSpec.describe "managing routes", :type => :request do
  describe "fetching details of a route" do
    before :each do
      FactoryGirl.create(:backend, :backend_id => "a-backend")
      FactoryGirl.create(:backend_route, :incoming_path => "/foo/bar", :route_type => "exact", :backend_id => "a-backend")
    end

    it "should return details of the route in JSON format" do
      get "/routes", :incoming_path => "/foo/bar", :route_type => "exact"

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "a-backend",
      })
    end

    it "should 404 for non-existent routes" do
      get "/routes", :incoming_path => "/foo/bar", :route_type => "prefix"
      expect(response.code.to_i).to eq(404)

      get "/routes", :incoming_path => "/foo", :route_type => "exact"
      expect(response.code.to_i).to eq(404)
    end
  end

  describe "creating a route" do
    before :each do
      FactoryGirl.create(:backend, :backend_id => 'a-backend')
    end

    it "should create a route" do
      put_json "/routes", :route => {:incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", :backend_id => "a-backend"}

      expect(response.code.to_i).to eq(201)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "a-backend",
      })

      route = Route.backend.where(:incoming_path => "/foo/bar", :route_type => "prefix").first
      expect(route).to be
      expect(route.backend_id).to eq("a-backend")
    end

    it "should return an error if given invalid data" do
      put_json "/routes", :route => {:incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", :backend_id => ""}

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      })

      route = Route.where(:incoming_path => "/foo/bar", :route_type => "prefix").first
      expect(route).not_to be
    end
  end

  describe "updating a route" do
    before :each do
      FactoryGirl.create(:backend, :backend_id => 'a-backend')
      FactoryGirl.create(:backend, :backend_id => 'another-backend')
      FactoryGirl.create(:backend_route, :incoming_path => "/foo/bar", :route_type => "prefix", :backend_id => "a-backend")
    end

    it "should update the route" do
      put_json "/routes", :route => {:incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", :backend_id => "another-backend"}

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "another-backend",
      })

      route = Route.backend.where(:incoming_path => "/foo/bar", :route_type => "prefix").first
      expect(route).to be
      expect(route.backend_id).to eq("another-backend")
    end

    it "should return an error if given invalid data" do
      put_json "/routes", :route => {:incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", "backend_id" => ""}

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      })

      route = Route.where(:incoming_path => "/foo/bar", :route_type => "prefix").first
      expect(route).to be
      expect(route.backend_id).to eq("a-backend")
    end

    it "should not blow up if not given the necessary route lookup keys" do
      put_json "/routes", {}
      expect(response.code.to_i).to eq(422)

      put "/routes"
      expect(response.code.to_i).to eq(422)
    end
  end

  describe "deleting a route" do
    before :each do
      FactoryGirl.create(:backend, :backend_id => "a-backend")
      FactoryGirl.create(:backend_route, :incoming_path => "/foo/bar", :route_type => "exact", :backend_id => "a-backend")
    end

    it "should delete the route" do
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "exact", :hard_delete => "true"

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "a-backend",
      })

      route = Route.where(:incoming_path => "/foo/bar", :routes => "exact").first
      expect(route).not_to be
    end

    it "should return 404 for non-existent routes" do
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "prefix"
      expect(response.code.to_i).to eq(404)

      delete "/routes", :incoming_path => "/foo", :route_type => "exact"
      expect(response.code.to_i).to eq(404)
    end
  end

  describe "committing the routes" do
    before :each do
      setup_router_reload_http_stub
    end

    it "should trigger a reload on the router, and return success" do
      post "/routes/commit"
      expect(response.code.to_i).to eq(200)

      expect(router_reload_http_stub).to have_been_requested
    end

    it "should return an error if reloading fails" do
      stub_router_reload_error

      post "/routes/commit"
      expect(response.code.to_i).to eq(500)
      expect(response.body).to eq("Failed to reload all routers")
    end
  end
end
