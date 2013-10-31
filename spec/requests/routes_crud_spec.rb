require 'spec_helper'

describe "managing routes" do
  before :each do
    setup_router_reload_http_stub
  end

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

    after :each do
      expect(router_reload_http_stub).not_to have_been_requested
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

      route = Route.backend.find_by_incoming_path_and_route_type("/foo/bar", "prefix")
      expect(route).to be
      expect(route.backend_id).to eq("a-backend")

      expect(router_reload_http_stub).to have_been_requested
    end

    it "should return an error if given invalid data" do
      put_json "/routes", :route => {:incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", :backend_id => ""}

      expect(response.code.to_i).to eq(400)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      })

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "prefix")
      expect(route).not_to be

      expect(router_reload_http_stub).not_to have_been_requested
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

      route = Route.backend.find_by_incoming_path_and_route_type("/foo/bar", "prefix")
      expect(route).to be
      expect(route.backend_id).to eq("another-backend")

      expect(router_reload_http_stub).to have_been_requested
    end

    it "should return an error if given invalid data" do
      put_json "/routes", :route => {:incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", "backend_id" => ""}

      expect(response.code.to_i).to eq(400)
      expect(JSON.parse(response.body)).to eq({
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      })

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "prefix")
      expect(route).to be
      expect(route.backend_id).to eq("a-backend")

      expect(router_reload_http_stub).not_to have_been_requested
    end

    it "should not blow up if not given the necessary route lookup keys" do
      put_json "/routes", {}
      expect(response.code.to_i).to eq(400)

      put "/routes"
      expect(response.code.to_i).to eq(400)

      expect(router_reload_http_stub).not_to have_been_requested
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

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "exact")
      expect(route).not_to be

      expect(router_reload_http_stub).to have_been_requested
    end

    it "should return 404 for non-existent routes" do
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "prefix"
      expect(response.code.to_i).to eq(404)

      delete "/routes", :incoming_path => "/foo", :route_type => "exact"
      expect(response.code.to_i).to eq(404)

      expect(router_reload_http_stub).not_to have_been_requested
    end
  end
end
