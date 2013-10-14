require 'spec_helper'

describe "Healthecheck" do

  it "should resposne on a healthcheck path" do
    get "/healthcheck"
    expect(response).to be_success
  end
end
