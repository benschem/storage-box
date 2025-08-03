# frozen_string_literal: true

FactoryBot.define do
  factory :invite do
    house
    inviter factory: :user
    invitee factory: :user
    invitee_email { Faker::Internet.unique.email }

    after(:build) do |invite|
      invite.house.users << invite.inviter unless invite.house.users.include?(invite.inviter)
    end

    trait :without_adding_inviter_to_house do
      after(:build) do |invite|
        invite.house.users.destroy_all
      end
    end
  end
end
