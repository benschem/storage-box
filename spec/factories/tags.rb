FactoryBot.define do
  factory :tag do
    association :house
    name { 'Car parts' }
  end
end
