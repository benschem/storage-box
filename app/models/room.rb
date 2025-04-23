class Room < ApplicationRecord
  belongs_to :house
  has_many :boxes
  has_many :direct_items, class_name: "Item"
  has_many :items, through: :boxes

  validates :name, presence: true
end
