FactoryBot.define do
  factory :invite do
    association :house
    association :inviter, factory: :user
    association :invitee, factory: :user
    invitee_email { Faker::Internet.unique.email }
  end
end
