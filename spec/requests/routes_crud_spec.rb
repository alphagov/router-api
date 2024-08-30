require "rails_helper"

RSpec.describe "managing routes", type: :request do
  context "when the user is not authenticated" do
    around do |example|
      ClimateControl.modify(GDS_SSO_MOCK_INVALID: "1") { example.run }
    end

    it "returns an unauthorized response" do
      get "/routes", params: { incoming_path: "/foo/bar" }
      expect(response).to be_unauthorized
    end
  end

  describe "fetching details of a route" do
    before :each do
      FactoryBot.create(:backend, backend_id: "a-backend")
      FactoryBot.create(:backend_route, incoming_path: "/foo/bar", route_type: "exact", backend_id: "a-backend")
    end

    it "should return details of the route in JSON format" do
      get "/routes", params: { incoming_path: "/foo/bar" }

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "a-backend",
      )
    end

    it "should 404 for non-existent routes" do
      get "/routes", params: { incoming_path: "/foo" }
      expect(response.code.to_i).to eq(404)
    end
  end

  describe "creating a route" do
    before :each do
      FactoryBot.create(:backend, backend_id: "a-backend")
    end

    it "should create a route" do
      put_json "/routes", route: { incoming_path: "/foo/bar", route_type: "prefix", handler: "backend", backend_id: "a-backend" }

      expect(response.code.to_i).to eq(201)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "a-backend",
      )

      route = Route.backend.where(incoming_path: "/foo/bar").first
      expect(route).to be
      expect(route.route_type).to eq("prefix")
      expect(route.backend_id).to eq("a-backend")
    end

    it "should return an error if given invalid data" do
      put_json "/routes", route: { incoming_path: "/foo/bar", route_type: "prefix", handler: "backend", backend_id: "" }

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      )

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be
    end
  end

  describe "updating a route" do
    before :each do
      FactoryBot.create(:backend, backend_id: "a-backend")
      FactoryBot.create(:backend, backend_id: "another-backend")
      @route = FactoryBot.create(:backend_route, incoming_path: "/foo/bar", route_type: "prefix", backend_id: "a-backend")
    end

    it "should update the route" do
      put_json "/routes", route: { incoming_path: "/foo/bar", route_type: "exact", handler: "backend", backend_id: "another-backend" }

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "another-backend",
      )

      route = Route.backend.where(incoming_path: "/foo/bar").first
      expect(route).to be
      expect(route.route_type).to eq("exact")
      expect(route.backend_id).to eq("another-backend")
    end

    it "should return an error if given invalid data" do
      put_json "/routes", route: { :incoming_path => "/foo/bar", :route_type => "prefix", :handler => "backend", "backend_id" => "" }

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "prefix",
        "handler" => "backend",
        "backend_id" => "",
        "errors" => {
          "backend_id" => ["can't be blank"],
        },
      )

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).to be
      expect(route.backend_id).to eq("a-backend")
    end

    it "should not blow up if not given the necessary route lookup keys" do
      put_json "/routes", {}
      expect(response.code.to_i).to eq(422)
    end

    it "should return a 400 when given bad JSON" do
      put "/routes", params: "i'm not json", headers: { "CONTENT_TYPE" => "application/json" }
      expect(response.status).to eq(400)

      put "/routes", params: "", headers: { "CONTENT_TYPE" => "application/json" }
      expect(response.code.to_i).to eq(400)
    end
  end

  describe "deleting a route" do
    before :each do
      FactoryBot.create(:backend, backend_id: "a-backend")
      FactoryBot.create(:backend_route, incoming_path: "/foo/bar", route_type: "exact", backend_id: "a-backend")
    end

    it "should delete the route" do
      delete "/routes", params: { incoming_path: "/foo/bar", hard_delete: "true" }

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq(
        "incoming_path" => "/foo/bar",
        "route_type" => "exact",
        "handler" => "backend",
        "backend_id" => "a-backend",
      )

      route = Route.where(incoming_path: "/foo/bar").first
      expect(route).not_to be
    end

    it "should return 404 for non-existent routes" do
      delete "/routes", params: { incoming_path: "/foo" }
      expect(response.code.to_i).to eq(404)
    end
  end

  describe "committing the routes" do
    it "should return success" do
      post "/routes/commit"
      expect(response.code.to_i).to eq(200)
    end
  end
end
