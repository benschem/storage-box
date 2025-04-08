class Household < ApplicationRecord
  has_many :users, through: :household_users
end
