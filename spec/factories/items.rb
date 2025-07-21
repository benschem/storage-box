FactoryBot.define do
  factory :item do
    name { 'backpack' }
    notes { 'green' }

    association :box
    association :house
    # association :room
    association :user
  end
end
