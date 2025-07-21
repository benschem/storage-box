FactoryBot.define do
  factory :room do
    association :house

    name { 'Garage' }
  end
end
