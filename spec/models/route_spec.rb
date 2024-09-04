require "rails_helper"

RSpec.describe Route, type: :model do
  describe "validations" do
    subject(:route) { FactoryBot.build(:route) }

    describe "on route_type" do
      it "is required" do
        route.route_type = ""
        expect(route).not_to be_valid
        expect(route.errors[:route_type].size).to eq(1)
      end

      it "will only allow specific values" do
        %w[prefix exact].each do |type|
          route.route_type = type
          expect(route).to be_valid
        end

        route.route_type = "foo"
        expect(route).not_to be_valid
        expect(route.errors[:route_type].size).to eq(1)
      end
    end

    describe "on incoming_path" do
      it "is required" do
        route.incoming_path = ""
        expect(route).not_to be_valid
        expect(route.errors[:incoming_path].size).to eq(1)
      end

      it "will allow an absolute URL path" do
        [
          "/",
          "/foo",
          "/foo/bar",
          "/foo-bar/baz",
          "/foo/BAR",
        ].each do |path|
          route.incoming_path = path
          expect(route).to be_valid
        end
      end

      it "will reject invalid URL paths" do
        [
          "not a URL path",
          "http://foo.example.com/bar",
          "bar/baz",
          "/foo/bar?baz=qux",
          "/foo/bar#baz",
        ].each do |path|
          route.incoming_path = path
          expect(route).not_to be_valid
          expect(route.errors[:incoming_path]).not_to be_empty
        end
      end

      it "will reject url paths with consecutive slashes or trailing slashes" do
        [
          "/foo//bar",
          "/foo/bar///",
          "//bar/baz",
          "//",
          "/foo/bar/",
        ].each do |path|
          route.incoming_path = path
          expect(route).not_to be_valid
          expect(route.errors[:incoming_path]).not_to be_empty
        end
      end

      describe "uniqueness" do
        it "is unique" do
          FactoryBot.create(:route, incoming_path: "/foo")
          route.incoming_path = "/foo"
          expect(route).not_to be_valid
          expect(route.errors[:incoming_path].size).to eq(1)
        end

        it "will have a db level uniqueness constraint" do
          FactoryBot.create(:route, incoming_path: "/foo")
          route.incoming_path = "/foo"

          expect {
            route.save validate: false
          }.to raise_error(Mongo::Error::OperationFailure)
        end
      end
    end

    describe "on handler" do
      it "is required" do
        route.handler = ""
        expect(route).not_to be_valid
        expect(route.errors[:handler].size).to eq(1)
      end

      it "will only allow specific values" do
        %w[backend redirect gone].each do |type|
          route.handler = type
          route.valid?
          expect(route.errors[:handler]).to be_empty
        end

        route.handler = "fooey"
        expect(route).not_to be_valid
        expect(route.errors[:handler].size).to eq(1)
      end
    end

    context "with handler set to 'backend'" do
      before { route.handler = "backend" }

      describe "on backend_id" do
        it "is required" do
          route.backend_id = ""
          expect(route).not_to be_valid
          expect(route.errors[:backend_id].size).to eq(1)
        end

        it "will map to an existing backend" do
          FactoryBot.create(:backend, backend_id: "foo")

          route.backend_id = "foo"
          expect(route).to be_valid

          route.backend_id = "bar"
          expect(route).not_to be_valid
          expect(route.errors[:backend_id].size).to eq(1)
        end
      end
    end

    context "with handler set to 'redirect'" do
      subject(:route) { FactoryBot.build(:redirect_route) }

      describe "segments_mode field" do
        it "is required" do
          route.segments_mode = ""
          expect(route).not_to be_valid
          expect(route.errors[:segments_mode].size).to eq(1)
        end

        it "must be either 'ignore' or 'preserve'" do
          route.segments_mode = "foobar"
          expect(route).not_to be_valid
          expect(route.errors[:segments_mode].size).to eq(1)

          route.segments_mode = "ignore"
          expect(route).to be_valid

          route.segments_mode = "preserve"
          expect(route).to be_valid
        end

        context "with an exact route" do
          subject(:route) { FactoryBot.create(:redirect_route, route_type: "exact") }

          it "defaults to ignore" do
            expect(route.segments_mode).to eq "ignore"
          end

          it "is not overriden" do
            route = FactoryBot.create(:redirect_route, route_type: "exact", segments_mode: "preserve")
            expect(route.segments_mode).to eq "preserve"
          end
        end

        context "with an prefix route" do
          subject(:route) { FactoryBot.create(:redirect_route, route_type: "prefix") }

          it "defaults to preserve" do
            expect(route.segments_mode).to eq "preserve"
          end

          it "is not overriden" do
            route = FactoryBot.create(:redirect_route, route_type: "prefix", segments_mode: "ignore")
            expect(route.segments_mode).to eq "ignore"
          end
        end
      end

      describe "redirect_to field" do
        it "is required" do
          route.redirect_to = ""
          expect(route).not_to be_valid
          expect(route.errors[:redirect_to].size).to eq(1)
        end

        it "accepts a path prefixed with a /" do
          route.redirect_to = "/thing"
          expect(route).to be_valid
        end

        it "rejects a path without a / prefix" do
          route.redirect_to = "thing"
          expect(route).to be_invalid
        end

        it "accepts an absolute URL" do
          route.redirect_to = "http://example.service.gov.uk.example.com/thing"
          expect(route).to be_valid
        end

        it "accepts an absolute URL" do
          route.redirect_to = "https://www.oisc.gov.uk"
          expect(route).to be_valid
        end

        it "rejects an invalid URI" do
          route.redirect_to = "invalid url"
          expect(route).to be_invalid
        end
      end

      describe "backend_id" do
        it "is set to nil" do
          expect(route.backend_id).to be nil
        end
      end

      context "and segments_mode set to 'ignore'" do
        subject(:route) { FactoryBot.build(:redirect_route, segments_mode: "ignore") }

        describe "redirect_to field" do
          it "will allow query strings" do
            route.redirect_to = "/foo/bar?thing"
            expect(route).to be_valid
          end

          it "will allow URL fragments" do
            route.redirect_to = "/foo/bar#section"
            expect(route).to be_valid
          end
        end
      end

      context "and segments_mode set to 'preserve'" do
        subject(:route) { FactoryBot.build(:redirect_route, segments_mode: "preserve") }

        describe "redirect_to field" do
          it "will reject query strings" do
            route.redirect_to = "/foo/bar?thing"
            expect(route).to be_invalid
          end

          it "will reject URL fragments" do
            route.redirect_to = "/foo/bar#section"
            expect(route).to be_invalid
          end
        end
      end
    end
  end

  describe "changing backend route to redirect route" do
    it "will clear the backend_id" do
      route = FactoryBot.create(:backend_route)
      route.update!(
        handler: "redirect",
        redirect_to: "/",
      )
      route.reload

      expect(route.backend_id).to be nil
    end
  end

  describe "as_json" do
    subject(:route) { FactoryBot.build(:redirect_route) }

    it "will not include the mongo id in its json representation" do
      expect(route.as_json).not_to have_key("_id")
    end

    it "will not include fields with nil values" do
      expect(route.as_json).not_to have_key("backend_id")
    end

    it "will include details of errors if any" do
      route.handler = ""
      route.valid?
      json_hash = route.as_json
      expect(json_hash).to have_key("errors")
      expect(json_hash["errors"]).to eq(handler: ["is not included in the list"])
    end

    it "will not include the errors key when there are none" do
      expect(route.as_json).not_to have_key("errors")
    end
  end

  describe "has_parent_prefix_routes?" do
    subject(:route) { FactoryBot.create(:route, incoming_path: "/foo/bar") }

    it "is false with no parents" do
      expect(route.has_parent_prefix_routes?).to be_falsey
    end

    it "is true with a parent prefix route" do
      FactoryBot.create(:route, incoming_path: "/foo", route_type: "prefix")
      expect(route.has_parent_prefix_routes?).to be_truthy
    end

    it "is false with a parent exact route" do
      FactoryBot.create(:route, incoming_path: "/foo", route_type: "exact")
      expect(route.has_parent_prefix_routes?).to be_falsey
    end

    it "is true with a prefix route at /" do
      FactoryBot.create(:route, incoming_path: "/", route_type: "prefix")
      expect(route.has_parent_prefix_routes?).to be_truthy
    end

    it "is false for a prefix route at /" do
      route.update!(incoming_path: "/", route_type: "prefix")
      expect(route.has_parent_prefix_routes?).to be_falsey
    end
  end

  describe "soft_delete" do
    subject(:route) { FactoryBot.create(:backend_route) }

    it "will destroy the route if it has a parent prefix route" do
      allow(route).to receive(:has_parent_prefix_routes?).and_return(true)
      route.soft_delete

      r = Route.where(incoming_path: route.incoming_path, route_type: route.route_type).first
      expect(r).not_to be
    end

    it "will convert the route to a gone route otherwise" do
      allow(route).to receive(:has_parent_prefix_routes?).and_return(false)
      route.soft_delete

      r = Route.where(incoming_path: route.incoming_path, route_type: route.route_type).first
      expect(r).to be
      expect(r.handler).to eq("gone")
    end
  end

  describe "cleaning child gone routes after create" do
    it "will delete a child gone route after creating a route" do
      child = FactoryBot.create(:gone_route, incoming_path: "/foo/bar/baz")
      new_route = Route.new(FactoryBot.attributes_for(:redirect_route, incoming_path: "/foo", route_type: "prefix"))
      new_route.save!

      r = Route.where(incoming_path: child.incoming_path, route_type: child.route_type).first
      expect(r).not_to be
    end

    it "will not delete anything if the creation fails" do
      child = FactoryBot.create(:gone_route, incoming_path: "/foo/bar/baz")
      new_route = Route.new(FactoryBot.attributes_for(:redirect_route, incoming_path: "/foo", route_type: "prefix", redirect_to: "not a url"))
      expect(new_route.save).to be_falsey

      r = Route.where(incoming_path: child.incoming_path, route_type: child.route_type).first
      expect(r).to be
    end

    it "will not delete anything if the created route is an exact route" do
      child = FactoryBot.create(:gone_route, incoming_path: "/foo/bar/baz")
      new_route = Route.new(FactoryBot.attributes_for(:redirect_route, incoming_path: "/foo", route_type: "exact"))
      new_route.save!

      r = Route.where(incoming_path: child.incoming_path, route_type: child.route_type).first
      expect(r).to be
    end

    it "will not delete a child route that's not a gone route" do
      child = FactoryBot.create(:redirect_route, incoming_path: "/foo/bar/baz")
      new_route = Route.new(FactoryBot.attributes_for(:redirect_route, incoming_path: "/foo", route_type: "prefix"))
      new_route.save!

      r = Route.where(incoming_path: child.incoming_path, route_type: child.route_type).first
      expect(r).to be
    end

    it "will not delete a route that's not a child" do
      child1 = FactoryBot.create(:redirect_route, incoming_path: "/bar/baz")
      child2 = FactoryBot.create(:redirect_route, incoming_path: "/foo/barbaz")
      new_route = Route.new(FactoryBot.attributes_for(:redirect_route, incoming_path: "/foo/bar", route_type: "prefix"))
      new_route.save!

      r = Route.where(incoming_path: child1.incoming_path, route_type: child1.route_type).first
      expect(r).to be
      r = Route.where(incoming_path: child2.incoming_path, route_type: child2.route_type).first
      expect(r).to be
    end

    it "will not delete itself when deleting routes" do
      new_route = Route.new(FactoryBot.attributes_for(:gone_route, incoming_path: "/foo/bar", route_type: "prefix"))
      new_route.save!

      r = Route.where(incoming_path: new_route.incoming_path, route_type: new_route.route_type).first
      expect(r).to be
    end
  end
end
