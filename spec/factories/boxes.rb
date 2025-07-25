FactoryBot.define do
  factory :box do
    association :room
    association :house
  end
end
