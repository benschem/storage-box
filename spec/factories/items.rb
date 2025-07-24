FactoryBot.define do
  factory :item do
    name { 'backpack' }
    notes { 'green' }

    association :house
    association :user

    # Make sure room belongs to same house
    room { association :room, house: house }

    trait :in_box do
      # Make sure box belongs to same room (and same house)
      box { association :box, room: room, house: house }
    end
  end
end
