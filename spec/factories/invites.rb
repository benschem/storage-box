# frozen_string_literal: true

FactoryBot.define do
  factory :invite do
    house
    sender factory: :user
    recipient factory: :user
    recipient_email { recipient.email }

    # Valid invite by default - sender must be a member of the house
    after(:build) do |invite|
      invite.house.users << invite.sender unless invite.house.users.include?(invite.sender)
    end

    # Invalid invite
    trait :without_adding_sender_to_house do
      after(:build) do |invite|
        invite.house.users.destroy_all
      end
    end

    # Invites can be emailed to people who are not yet users
    trait :email_only do
      recipient { nil }
      recipient_email { Faker::Internet.unique.email }
    end
  end
end
