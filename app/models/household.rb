class Household < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :rooms
  has_many :boxes, through: :rooms

  validates :address, presence: true
end
