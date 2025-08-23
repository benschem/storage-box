# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    name { Faker::Commerce.unique.department }

    trait :with_items do
      transient do
        items_count { 1 }
      end

      after(:create) do |tag, args|
        create_list(:tagging, args.items_count, tag: tag)
      end
    end
  end
end
