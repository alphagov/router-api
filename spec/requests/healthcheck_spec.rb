require 'rails_helper'

describe "Healthecheck", :type => :request do

  it "should resposnd on a healthcheck path" do
    get "/healthcheck"
    expect(response).to be_success
  end
end
