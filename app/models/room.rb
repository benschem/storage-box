class Room < ApplicationRecord
  belongs_to :house
  has_many :boxes
  has_many :items, through: :boxes

  validates :name, presence: true
end
