require 'spec_helper'

describe "auto creation and deletion of gone routes" do

  describe "soft-deleting a route" do
    it "should convert it into a 'gone' route"

    it "should not convert it into a 'gone' route if hard deletion is requested"

    it "should fully delete it if it has a parent prefix route"

    it "should fully delete an exact route it there is a prefix route for the same path"

  end

  describe "cleaning up gone routes on prefix route creation" do
    it "should delete a gone route when a parent prefix route is created"

    it "should delete an exact gone route when a prefix route is created with the same path"

  end
end
