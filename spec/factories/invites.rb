# frozen_string_literal: true

FactoryBot.define do
  factory :invite do
    house
    sender factory: :user
    recipient factory: :user
    recipient_email { Faker::Internet.unique.email }

    after(:build) do |invite|
      invite.house.users << invite.sender unless invite.house.users.include?(invite.sender)
    end

    trait :without_adding_sender_to_house do
      after(:build) do |invite|
        invite.house.users.destroy_all
      end
    end
  end
end
