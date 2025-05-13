class House < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :rooms, dependent: :restrict_with_error
  has_many :boxes, through: :rooms
  has_many :items
  has_many :invites, dependent: :destroy

  validates :name, presence: true
end
