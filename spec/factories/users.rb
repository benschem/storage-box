# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { 'verySecurePassword123' }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
