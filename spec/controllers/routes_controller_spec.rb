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
    # Simulate race condition by creating a clashing DB object and stubbing
    # find_and_initialize_by to return something new - as if the item didn't
    # exist when it was called.
    FactoryBot.create(:route, incoming_path: "/foo/bar")
    erroring_route = Route.new(incoming_path: "/foo/bar")
    allow(Route).to receive(:find_or_initialize_by).and_return(erroring_route)

    allow(erroring_route).to receive(:update).and_wrap_original do |_, attributes|
      erroring_route.assign_attributes(attributes)
      erroring_route.save!(validate: false)
    end

    expect(Route).to receive(:find_or_initialize_by).exactly(3).times

    expect { put :update, body: data, format: :json }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end
end
