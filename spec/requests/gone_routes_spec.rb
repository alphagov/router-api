require 'spec_helper'

describe "auto creation and deletion of gone routes" do

  describe "soft-deleting a route" do
    before :each do
      FactoryGirl.create(:backend, :backend_id => "a-backend")
      FactoryGirl.create(:backend_route, :incoming_path => "/foo/bar", :route_type => "exact", :backend_id => "a-backend")
    end

    it "should convert it into a 'gone' route" do
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "exact"

      expect(response.code.to_i).to eq(200)

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "exact")
      expect(route).to be
      expect(route.handler).to eq("gone")
    end

    it "should not convert it into a 'gone' route if hard deletion is requested" do
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "exact", :hard_delete => "true"

      expect(response.code.to_i).to eq(200)

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "exact")
      expect(route).not_to be
    end

    it "should fully delete it if it has a parent prefix route" do
      FactoryGirl.create(:backend_route, :incoming_path => "/foo", :route_type => "prefix")
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "exact"

      expect(response.code.to_i).to eq(200)

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "exact")
      expect(route).not_to be
    end

    it "should fully delete an exact route it there is a prefix route for the same path" do
      FactoryGirl.create(:backend_route, :incoming_path => "/foo/bar", :route_type => "prefix")
      delete "/routes", :incoming_path => "/foo/bar", :route_type => "exact"

      expect(response.code.to_i).to eq(200)

      route = Route.find_by_incoming_path_and_route_type("/foo/bar", "exact")
      expect(route).not_to be
    end
  end

  describe "cleaning up gone routes on prefix route creation" do
    it "should delete a gone route when a parent prefix route is created"

    it "should delete an exact gone route when a prefix route is created with the same path"

  end
end
