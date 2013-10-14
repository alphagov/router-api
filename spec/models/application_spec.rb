require 'spec_helper'

describe Application do
  describe "validations" do
    before :each do
      @application = FactoryGirl.build(:application)
    end

    describe "on application_id" do
      it "should be required" do
        @application.application_id = ''
        expect(@application).not_to be_valid
        expect(@application).to have(1).error_on(:application_id)
      end

      it "should be a slug format" do
        @application.application_id = 'not a slug'
        expect(@application).not_to be_valid
        expect(@application).to have(1).error_on(:application_id)
      end

      it "should be unique" do
        FactoryGirl.create(:application, :application_id => 'a-backend')
        @application.application_id = 'a-backend'
        expect(@application).not_to be_valid
        expect(@application).to have(1).error_on(:application_id)
      end

      it "should have a db level uniqueness constraint" do
        FactoryGirl.create(:application, :application_id => 'a-backend')
        @application.application_id = 'a-backend'
        expect {
          @application.save :validate => false
        }.to raise_error(Mongo::OperationFailure)
      end
    end

    describe "on backend_url" do
      it "should be required" do
        @application.backend_url = ''
        expect(@application).not_to be_valid
        expect(@application).to have(1).error_on(:backend_url)
      end

      it "should look like a URL"
    end
  end
end
