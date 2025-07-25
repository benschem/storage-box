FactoryBot.define do
  factory :room do
    association :house

    sequence(:name) { |n| "room_#{n}" }
  end
end
