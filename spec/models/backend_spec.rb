require 'rails_helper'

RSpec.describe Backend, type: :model do
  describe "validations" do
    subject(:backend) { FactoryGirl.build(:backend) }

    describe "on backend_id" do
      it "is required" do
        backend.backend_id = ''
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_id].size).to eq(1)
      end

      it "is a slug format" do
        backend.backend_id = 'not a slug'
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_id].size).to eq(1)
      end

      it "is unique" do
        FactoryGirl.create(:backend, backend_id: 'a-backend')
        backend.backend_id = 'a-backend'
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_id].size).to eq(1)
      end

      it "will have a db level uniqueness constraint" do
        FactoryGirl.create(:backend, backend_id: 'a-backend')
        backend.backend_id = 'a-backend'
        expect {
          backend.save validate: false
        }.to raise_error(Mongo::Error::OperationFailure)
      end
    end

    describe "on backend_url" do
      it "is required" do
        backend.backend_url = ''
        expect(backend).not_to be_valid
        expect(backend.errors[:backend_url].size).to eq(1)
      end

      it "will accept an HTTP URL" do
        backend.backend_url = "http://foo.example.com/"
        expect(backend).to be_valid
      end

      it "will accept an HTTPS URL" do
        backend.backend_url = "https://foo.example.com/"
        expect(backend).to be_valid
      end

      it "will reject invalid URLs" do
        [
          "I'm not an URL",
          "ftp://example.org/foo/bar",
          "mailto:me@example.com",
          "www.example.org/foo",
          "/relative/url",
          "http://",
          "http:foo",
          "http://foo.example.com/?bar=baz",
          "http://foo.example.com/#bar",
        ].each do |url|
          backend.backend_url = url
          expect(backend).not_to be_valid
          expect(backend.errors[:backend_url].size).to eq(1)
        end
      end
    end
  end

  describe "as_json" do
    subject(:backend) { FactoryGirl.build(:backend) }

    it "will not include the mongo id in its json representation" do
      expect(backend.as_json).not_to have_key("_id")
    end

    it "will include details of errors if any" do
      backend.backend_id = ""
      backend.valid?
      json_hash = backend.as_json
      expect(json_hash).to have_key("errors")
      expect(json_hash["errors"]).to eq({
        backend_id: ["can't be blank"],
      })
    end

    it "will not include the errors key when there are none" do
      expect(backend.as_json).not_to have_key("errors")
    end
  end

  describe "destroying" do
    subject(:backend) { FactoryGirl.create(:backend) }

    it "will not allow destroy when it has associated routes" do
      FactoryGirl.create(:backend_route, backend_id: backend.backend_id)

      expect { backend.destroy }.not_to change { Backend.count }
    end

    it "will allow destroy otherwise" do
      backend2 = FactoryGirl.create(:backend)
      FactoryGirl.create(:backend_route, backend_id: backend2.backend_id)

      backend.destroy

      expect(Backend.count).to eq 1
    end
  end
end
