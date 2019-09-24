require "rails_helper"

RSpec.describe "Healthecheck", type: :request do
  it "should resposnd on a healthcheck path" do
    get "/healthcheck"
    expect(response).to be_successful
  end
end
