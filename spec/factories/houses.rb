FactoryBot.define do
  factory :house do
    sequence(:name) { |n| "house_#{n}" }
  end
end
