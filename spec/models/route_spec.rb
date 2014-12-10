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
          "/foo/bar#baz",
        ].each do |path|
          @route.incoming_path = path
          expect(@route).not_to be_valid
          expect(@route).to have(1).error_on(:incoming_path)
        end
      end

      it "should reject url paths with consecutive slashes or trailing slashes" do
        [
          "/foo//bar",
          "/foo/bar///",
          "//bar/baz",
          "//",
          "/foo/bar/",
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
        }.to raise_error(Moped::Errors::OperationFailure)
      end
    end

    describe "on handler" do
      it "should be required" do
        @route.handler = ""
        expect(@route).not_to be_valid
        expect(@route).to have(1).error_on(:handler)
      end

      it "should only allow specific values" do
        %w(backend redirect gone).each do |type|
          @route.handler = type
          @route.valid?
          expect(@route).to have(0).errors_on(:handler)
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

    context "with handler set to 'redirect'" do
      before :each do
        @route = FactoryGirl.build(:redirect_route)
      end

      describe "redirect_to field" do
        it "should be required" do
          @route.redirect_to = ""
          expect(@route).not_to be_valid
          expect(@route).to have(1).error_on(:redirect_to)
        end

        it "should be a valid URL" do
          @route.redirect_to = "\jkhsdfgjkhdjskfgh//fdf#th"
          expect(@route).not_to be_valid
          expect(@route).to have(1).error_on(:redirect_to)
        end
      end
    end

    context "with handler set to 'redirect' and route_type set to 'exact'" do
      before :each do
        @route = FactoryGirl.build(:redirect_route, :route_type => 'exact')
      end

      describe "redirect_to field" do
        it "should allow query strings" do
          @route.redirect_to = "/foo/bar?thing"
          expect(@route).to be_valid
        end

        it "should allow URL fragments" do
          @route.redirect_to = "/foo/bar#section"
          expect(@route).to be_valid
        end

        it "should allow external URLs" do
          @route.redirect_to = "http://example.com/thing"
          expect(@route).to be_valid
        end

        it "should reject invalid URL paths" do
          [
            "not a URL path",
            "bar/baz",
            "/foo//bar",
          ].each do |path|
            @route.redirect_to = path
            expect(@route).not_to be_valid
            expect(@route).to have(1).error_on(:redirect_to)
          end
        end
      end
    end
  end

  describe "as_json" do
    before :each do
      @route = FactoryGirl.build(:redirect_route)
    end

    it "should not include the mongo id in its json representation" do
      expect(@route.as_json).not_to have_key("_id")
    end

    it "should not include fields with nil values" do
      expect(@route.as_json).not_to have_key("backend_id")
    end

    it "should include details of errors if any" do
      @route.handler = ""
      @route.valid?
      json_hash = @route.as_json
      expect(json_hash).to have_key("errors")
      expect(json_hash["errors"]).to eq({
        :handler => ["is not included in the list"],
      })
    end

    it "should not include the errors key when there are none" do
      expect(@route.as_json).not_to have_key("errors")
    end
  end

  describe "has_parent_prefix_routes?" do
    before :each do
      @route = FactoryGirl.create(:route, :incoming_path => "/foo/bar")
    end

    it "should be false with no parents" do
      expect(@route.has_parent_prefix_routes?).to be_false
    end

    it "should be true with a parent prefix route" do
      FactoryGirl.create(:route, :incoming_path => "/foo", :route_type => "prefix")
      expect(@route.has_parent_prefix_routes?).to be_true
    end

    it "should be false with a parent exact route" do
      FactoryGirl.create(:route, :incoming_path => "/foo", :route_type => "exact")
      expect(@route.has_parent_prefix_routes?).to be_false
    end

    it "should be true with a prefix route at /" do
      FactoryGirl.create(:route, :incoming_path => "/", :route_type => "prefix")
      expect(@route.has_parent_prefix_routes?).to be_true
    end

    it "should be true for an exact route with a prefix route at the same path" do
      @route.update_attributes!(:route_type => "exact")
      FactoryGirl.create(:route, :incoming_path => "/foo/bar", :route_type => "prefix")
      expect(@route.has_parent_prefix_routes?).to be_true
    end

    it "should be false for a prefix route with an exact route at the same path" do
      @route.update_attributes!(:route_type => "prefix")
      FactoryGirl.create(:route, :incoming_path => "/foo/bar", :route_type => "exact")
      expect(@route.has_parent_prefix_routes?).to be_false
    end

    it "should be false for a prefix route at /" do
      @route.update_attributes(:incoming_path => "/", :route_type => "prefix")
      expect(@route.has_parent_prefix_routes?).to be_false
    end
  end

  describe "soft_delete" do
    before :each do
      @route = FactoryGirl.create(:backend_route)
    end

    it "should destroy the route if it has a parent prefix route" do
      @route.stub(:has_parent_prefix_routes?).and_return(true)
      @route.soft_delete

      r = Route.where(:incoming_path => @route.incoming_path, :route_type => @route.route_type).first
      expect(r).not_to be
    end

    it "should convert the route to a gone route otherwise" do
      @route.stub(:has_parent_prefix_routes?).and_return(false)
      @route.soft_delete

      r = Route.where(:incoming_path => @route.incoming_path, :route_type => @route.route_type).first
      expect(r).to be
      expect(r.handler).to eq("gone")
    end
  end

  describe "cleaning child gone routes after create" do

    it "should delete a child gone route after creating a route" do
      child = FactoryGirl.create(:gone_route, :incoming_path => "/foo/bar/baz")
      new_route = Route.new(FactoryGirl.attributes_for(:redirect_route, :incoming_path => "/foo", :route_type => "prefix"))
      new_route.save!

      r = Route.where(:incoming_path => child.incoming_path, :route_type => child.route_type).first
      expect(r).not_to be
    end

    it "should not delete anything if the creation fails" do
      child = FactoryGirl.create(:gone_route, :incoming_path => "/foo/bar/baz")
      new_route = Route.new(FactoryGirl.attributes_for(:redirect_route, :incoming_path => "/foo", :route_type => "prefix", :redirect_to => "not a url"))
      expect(new_route.save).to be_false

      r = Route.where(:incoming_path => child.incoming_path, :route_type => child.route_type).first
      expect(r).to be
    end

    it "should not delete anything if the created route is an exact route" do
      child = FactoryGirl.create(:gone_route, :incoming_path => "/foo/bar/baz")
      new_route = Route.new(FactoryGirl.attributes_for(:redirect_route, :incoming_path => "/foo", :route_type => "exact"))
      new_route.save!

      r = Route.where(:incoming_path => child.incoming_path, :route_type => child.route_type).first
      expect(r).to be
    end

    it "should not delete a child route that's not a gone route" do
      child = FactoryGirl.create(:redirect_route, :incoming_path => "/foo/bar/baz")
      new_route = Route.new(FactoryGirl.attributes_for(:redirect_route, :incoming_path => "/foo", :route_type => "prefix"))
      new_route.save!

      r = Route.where(:incoming_path => child.incoming_path, :route_type => child.route_type).first
      expect(r).to be
    end

    it "should not delete a route that's not a child" do
      child1 = FactoryGirl.create(:redirect_route, :incoming_path => "/bar/baz")
      child2 = FactoryGirl.create(:redirect_route, :incoming_path => "/foo/barbaz")
      new_route = Route.new(FactoryGirl.attributes_for(:redirect_route, :incoming_path => "/foo/bar", :route_type => "prefix"))
      new_route.save!

      r = Route.where(:incoming_path => child1.incoming_path, :route_type => child1.route_type).first
      expect(r).to be
      r = Route.where(:incoming_path => child2.incoming_path, :route_type => child2.route_type).first
      expect(r).to be
    end

    it "should not delete itself when deleting routes" do
      new_route = Route.new(FactoryGirl.attributes_for(:gone_route, :incoming_path => "/foo/bar", :route_type => "prefix"))
      new_route.save!

      r = Route.where(:incoming_path => new_route.incoming_path, :route_type => new_route.route_type).first
      expect(r).to be
    end

    it "should delete an exact gone route with the same path as the created prefix route" do
      child = FactoryGirl.create(:gone_route, :incoming_path => "/foo/bar", :route_type => "exact")
      new_route = Route.new(FactoryGirl.attributes_for(:redirect_route, :incoming_path => "/foo/bar", :route_type => "prefix"))
      new_route.save!

      r = Route.where(:incoming_path => child.incoming_path, :route_type => child.route_type).first
      expect(r).not_to be
    end
  end
end
