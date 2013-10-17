# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :route do
    route_type                "prefix"
    sequence(:incoming_path)  {|n| "/path/#{n}"}
    handler                   "backend"
    sequence(:backend_id)     {|n| "backend-#{n}"}
  end
end
