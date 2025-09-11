# frozen_string_literal: true

# Represents a room or area where items can be stored
class Room < ApplicationRecord
  belongs_to :house, counter_cache: true
  has_many :boxes, dependent: :restrict_with_error
  has_many :unboxed_items, class_name: 'Item', dependent: :restrict_with_error
  has_many :boxed_items, through: :boxes, source: :items

  validates :name, presence: true

  scope :in_house, ->(house) { where(house_id: house) }

  def items
    Item.where(id: (unboxed_items.ids + boxed_items.ids))
  end
end
