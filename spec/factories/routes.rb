# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :route do
    route_type                { "prefix" }
    sequence(:incoming_path)  { |n| "/path/#{n}" }
    handler                   { "gone" }

    factory :backend_route do
      handler       { "backend" }
      backend_id    { (Backend.first || create(:backend)).backend_id }
    end

    factory :redirect_route do
      handler { "redirect" }
      redirect_to { "/bar" }
      redirect_type { "permanent" }
    end

    factory :gone_route do
    end
  end
end
