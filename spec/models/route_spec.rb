require 'spec_helper'

describe Route do
  describe "validations" do
    before :each do
      @route = FactoryGirl.build(:route)
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

      it "should allow an absolute URL path" do
        [
          "/",
          "/foo",
          "/foo/bar",
          "/foo-bar/baz",
          "/foo/BAR",
        ].each do |path|
          @route.incoming_path = path
          expect(@route).to be_valid
        end
      end

      it "should reject invalid URL paths" do
        [
          "not a URL path",
          "http://foo.example.com/bar",
          "bar/baz",
          "/foo/bar?baz=qux",
        ].each do |path|
          @route.incoming_path = path
          expect(@route).not_to be_valid
          expect(@route).to have(1).error_on(:incoming_path)
        end
      end
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

    describe "on handler" do
      it "should be required" do
        @route.handler = ""
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:handler)
      end

      it "should only allow specific values" do
        %w(backend).each do |type|
          @route.handler = type
          expect(@route).to be_valid
        end

        @route.handler = "fooey"
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:handler)
      end
    end

    context "with handler set to 'backend'" do
      before :each do
        @route.handler = "backend"
      end

      describe "on backend_id" do
        it "should be required" do
          @route.backend_id = ''
          expect(@route).not_to be_valid
          expect(@route).to have(1).error_on(:backend_id)
        end

        it "should map to an existing backend" do
          backend = FactoryGirl.create(:backend, :backend_id => "foo")

          @route.backend_id = "foo"
          expect(@route).to be_valid

          @route.backend_id = "bar"
          expect(@route).not_to be_valid
          expect(@route).to have(1).error_on(:backend_id)
        end
      end
    end
  end
end
