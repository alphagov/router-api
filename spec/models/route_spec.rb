require 'spec_helper'

describe Route do
  describe "validations" do
    before :each do
      @route = FactoryGirl.build(:route)
    end

    describe "on application_id" do
      it "should be required" do
        @route.application_id = ''
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:application_id)
      end

      it "should map to an existing application"
    end

    describe "on route_type" do
      it "should be required" do
        @route.route_type = ''
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:route_type)
      end

      it "should only allow specific values" do
        %w(prefix exact).each do |type|
          @route.route_type = type
          expect(@route).to be_valid
        end

        @route.route_type = 'foo'
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:route_type)
      end
    end

    describe "on incoming_path" do
      it "should be required" do
        @route.incoming_path = ""
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:incoming_path)
      end

      it "should look like an absolute URL path"
    end

    describe "path uniqueness constraints" do
      it "should allow duplicate paths with different route_types" do
        FactoryGirl.create(:route, :route_type => "prefix", :incoming_path => "/foo")
        @route.route_type = "exact"
        @route.incoming_path = "/foo"
        expect(@route).to be_valid

        # Ensure db constraint allows this combination
        expect {
          @route.save!
        }.not_to raise_error
      end

      it "should require a unique path per route_type" do
        FactoryGirl.create(:route, :route_type => "prefix", :incoming_path => "/foo")
        @route.route_type = "prefix"
        @route.incoming_path = "/foo"
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:incoming_path)
      end

      it "should have a db level uniqueness constraint" do
        FactoryGirl.create(:route, :route_type => "prefix", :incoming_path => "/foo")
        @route.route_type = "prefix"
        @route.incoming_path = "/foo"
        expect {
          @route.save :validate => false
        }.to raise_error(Mongo::OperationFailure)
      end
    end

  end
end
