require 'rails_helper'

RSpec.describe "auto creation and deletion of gone routes", type: :request do
  describe "soft-deleting a route" do
    before :each do
      FactoryGirl.create(:backend, backend_id: "a-backend")
      FactoryGirl.create(:backend_route, incoming_path: "/foo/bar", route_type: "exact", backend_id: "a-backend")
    end

    it "should convert it into a 'gone' route" do
      delete "/routes", params: { incoming_path: "/foo/bar" }

      expect(response.code.to_i).to eq(200)

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).to be
      expect(route.route_type).to eq("exact")
      expect(route.handler).to eq("gone")
    end

    it "should not convert it into a 'gone' route if hard deletion is requested" do
      delete "/routes", params: { incoming_path: "/foo/bar", hard_delete: "true" }

      expect(response.code.to_i).to eq(200)

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be
    end

    it "should fully delete it if it has a parent prefix route" do
      FactoryGirl.create(:backend_route, incoming_path: "/foo", route_type: "prefix")
      delete "/routes", params: { incoming_path: "/foo/bar" }

      expect(response.code.to_i).to eq(200)

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be
    end
  end

  describe "cleaning up gone routes on prefix route creation" do
    before :each do
      FactoryGirl.create(:backend, backend_id: "a-backend")
      FactoryGirl.create(:gone_route, incoming_path: "/foo/bar", route_type: "exact")
    end

    it "should delete a gone route when a parent prefix route is created" do
      put_json "/routes", route: {incoming_path: "/foo", route_type: "prefix", handler: "backend", backend_id: "a-backend"}

      expect(response.code.to_i).to eq(201)

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be
    end
  end
end
