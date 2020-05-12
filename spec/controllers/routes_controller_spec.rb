require "rails_helper"
require Rails.root.join("app/models/route")

RSpec.describe RoutesController, type: :controller do
  before do
    authenticate_as_stub_user
    FactoryBot.create(:backend, backend_id: "a-backend")
  end

  let(:data) do
    {
      route: {
        incoming_path: "/foo/bar", route_type: "prefix", handler: "backend", backend_id: "a-backend"
      },
    }.to_json
  end

  it "should not fail on multiple simultaneous requests" do
    bypass_rescue
    failed = false

    threads = 4.times.map do
      Thread.new do
        put :update, body: data, format: :json
      rescue Mongo::Error::OperationFailure
        failed = true
      rescue AbstractController::DoubleRenderError
        # this error will happen if both threads succeed, so this is fine.
      end
    end
    threads.each(&:join)

    expect(failed).to be false
  end
end
