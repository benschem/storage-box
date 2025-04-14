class House < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :rooms
  has_many :boxes, through: :rooms, dependent: :destroy
  has_many :items, through: :boxes, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :address, presence: true
end
