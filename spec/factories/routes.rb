# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :route do
    route_type                "prefix"
    sequence(:incoming_path)  {|n| "/path/#{n}"}
    handler                   "backend"
    backend_id                { (Backend.first || create(:backend)).backend_id }

    factory :backend_route do
    end
  end
end
