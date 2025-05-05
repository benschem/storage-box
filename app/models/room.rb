class Room < ApplicationRecord
  belongs_to :house, counter_cache: true
  has_many :boxes, dependent: :destroy
  has_many :direct_items, class_name: "Item"
  has_many :box_items, through: :boxes, source: :items

  validates :name, presence: true

  def items
    Item.where(id: (direct_items.ids + box_items.ids))
  end
end
