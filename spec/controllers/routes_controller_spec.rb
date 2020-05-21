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

  it "should retry on multiple simultaneous requests" do
    allow(Route).to receive(:find_or_initialize_by)
      .and_raise(Mongo::Error::OperationFailure, Route::DUPLICATE_KEY_ERROR)

    expect(Route).to receive(:find_or_initialize_by).exactly(3).times

    expect { put :update, body: data, format: :json }
      .to raise_error(Mongo::Error::OperationFailure)
  end
end
