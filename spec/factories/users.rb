FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { '123456' }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
