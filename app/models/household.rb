class Household < ApplicationRecord
  has_and_belongs_to_many :users

  validates :address, presence: true
end
