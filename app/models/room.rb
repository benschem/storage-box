class Room < ApplicationRecord
  belongs_to :house, counter_cache: true
  has_many :boxes, dependent: :destroy
  has_many :unboxed_items, class_name: 'Item'
  has_many :boxed_items, through: :boxes, source: :items

  validates :name, presence: true

  def items
    Item.where(id: (unboxed_items.ids + boxed_items.ids))
  end
end
