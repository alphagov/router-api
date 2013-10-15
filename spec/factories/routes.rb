# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :route do
    sequence(:backend_id)     {|n| "backend-#{n}"}
    route_type                "prefix"
    sequence(:incoming_path)  {|n| "/path/#{n}"}
  end
end
