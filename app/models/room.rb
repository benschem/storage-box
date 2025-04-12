class Room < ApplicationRecord
  belongs_to :household
  has_many :boxes
  has_many :items, through: :boxes

  validates :name, presence: true
end
