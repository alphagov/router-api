require 'rails_helper'

RSpec.describe "managing backends", type: :request do
  describe "getting details of a backend" do
    it "should return the backend details as JSON" do
      FactoryGirl.create(:backend, backend_id: "foo", backend_url: "http://foo.example.com/")

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
  end

  describe "creating a backend" do
    it "should create a new backend" do
      put_json "/backends/foo", backend: {backend_url: "http://foo.example.com/"}

      expect(response.code.to_i).to eq(201)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
      })

      backend = Backend.where(backend_id: "foo").first
      expect(backend).to be
      expect(backend.backend_url).to eq("http://foo.example.com/")
    end

    it "should return an error if given invalid data" do
      put_json "/backends/foo", backend: {backend_url: ""}

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "",
        "errors" => {
          "backend_url" => ["is not a valid HTTP URL"],
        }
      })

      backend = Backend.where(backend_id: "foo").first
      expect(backend).to be_nil
    end

    it "should 404 for a backend_id that doesn't look like a slug" do
      put_json "/backends/foo+bar", backend: {backend_url: "http://foo.example.com/"}
      expect(response.code.to_i).to eq(404)
    end

    it "should return a 400 when given bad JSON" do
      put "/backends/foo", params: "i'm not json", headers: { "CONTENT_TYPE" => "application/json" }
      expect(response.status).to eq(400)
    end
  end

  describe "updating a backend" do
    it "should update the backend" do
      backend = FactoryGirl.create(:backend, backend_id: "foo", backend_url: "http://something.example.com/")
      put_json "/backends/foo", backend: {backend_url: "http://something-else.example.com/"}

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://something-else.example.com/",
      })

      backend.reload
      expect(backend.backend_url).to eq("http://something-else.example.com/")
    end

    it "should return an error if given invalid data" do
      backend = FactoryGirl.create(:backend, backend_id: "foo", backend_url: "http://something.example.com/")
      put_json "/backends/foo", backend: {backend_url: ""}

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "",
        "errors" => {
          "backend_url" => ["is not a valid HTTP URL"],
        }
      })

      backend.reload
      expect(backend.backend_url).to eq("http://something.example.com/")
    end
  end

  describe "deleting a backend" do
    before :each do
      @backend = FactoryGirl.create(:backend, backend_id: "foo", backend_url: "http://foo.example.com/")
    end

    it "should delete the backend" do
      delete "/backends/foo"

      expect(response.code.to_i).to eq(200)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
      })

      backend = Backend.where(backend_id: "foo").first
      expect(backend).not_to be
    end

    it "should not allow deletion of a backend with associated routes" do
      FactoryGirl.create(:backend_route, backend_id: @backend.backend_id)

      delete "/backends/foo"

      expect(response.code.to_i).to eq(422)
      expect(JSON.parse(response.body)).to eq({
        "backend_id" => "foo",
        "backend_url" => "http://foo.example.com/",
        "errors" => {
          "base" => ["Backend has routes - can't delete"],
        },
      })

      backend = Backend.where(backend_id: "foo").first
      expect(backend).to be
    end

    it "should 404 for a non-existent backend" do
      delete "/backends/non-existent"
      expect(response.code.to_i).to eq(404)
    end
  end
end
