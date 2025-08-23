# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    notes { "#{Faker::Commerce.color} #{Faker::Commerce.material} #{Faker::Commerce.brand} from #{Faker::Commerce.vendor}" }

    house
    user
    room { association :room, house: house } # Make sure room belongs to same house

    trait :in_box do
      box { association :box, room: room, house: house } # Make sure box belongs to same room (and same house)
    end

    trait :with_tags do
      transient do
        tags_count { 1 }
      end

      after(:create) do |item, args|
        create_list(:tagging, args.tags_count, item: item)
      end
    end
  end
end
