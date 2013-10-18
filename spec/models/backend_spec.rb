require 'spec_helper'

describe Backend do
  describe "validations" do
    before :each do
      @backend = FactoryGirl.build(:backend)
    end

    describe "on backend_id" do
      it "should be required" do
        @backend.backend_id = ''
        expect(@backend).not_to be_valid
        expect(@backend).to have(1).error_on(:backend_id)
      end

      it "should be a slug format" do
        @backend.backend_id = 'not a slug'
        expect(@backend).not_to be_valid
        expect(@backend).to have(1).error_on(:backend_id)
      end

      it "should be unique" do
        FactoryGirl.create(:backend, :backend_id => 'a-backend')
        @backend.backend_id = 'a-backend'
        expect(@backend).not_to be_valid
        expect(@backend).to have(1).error_on(:backend_id)
      end

      it "should have a db level uniqueness constraint" do
        FactoryGirl.create(:backend, :backend_id => 'a-backend')
        @backend.backend_id = 'a-backend'
        expect {
          @backend.save :validate => false
        }.to raise_error(Mongo::OperationFailure)
      end
    end

    describe "on backend_url" do
      it "should be required" do
        @backend.backend_url = ''
        expect(@backend).not_to be_valid
        expect(@backend).to have(1).error_on(:backend_url)
      end

      it "should look like a URL"
    end
  end

  it "should not include the mongo id in its json representation" do
    be = FactoryGirl.build(:backend)
    expect(be.as_json).not_to have_key("id")
  end

  describe "destroying" do
    before :each do
      @backend = FactoryGirl.create(:backend)
    end

    it "should not allow destroy when it has associated routes" do
      FactoryGirl.create(:backend_route, :backend_id => @backend.backend_id)

      expect(@backend.destroy).to be_false

      backend = Backend.find_by_backend_id(@backend.backend_id)
      expect(backend).to be
    end

    it "should allow destroy otherwise" do
      backend2 = FactoryGirl.create(:backend)
      FactoryGirl.create(:backend_route, :backend_id => backend2.backend_id)

      expect(@backend.destroy).to be_true

      backend = Backend.find_by_backend_id(@backend.backend_id)
      expect(backend).not_to be
    end
  end
end
