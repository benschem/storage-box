class Room < ApplicationRecord
  belongs_to :household
  has_many :boxes

  validates :name, presence: true
end
