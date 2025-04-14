class Item < ApplicationRecord
  belongs_to :box

  has_one_attached :image

  validates :name, presence: true
end
