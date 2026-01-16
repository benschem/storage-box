# frozen_string_literal: true

# An item in a users' house
class Item < ApplicationRecord
  include Searchable

  belongs_to :user
  belongs_to :house, counter_cache: true
  belongs_to :room
  belongs_to :box, optional: true

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  has_one_attached :image
  attr_accessor :remove_image

  after_save :purge_image, if: -> { remove_image == '1' }

  validates :name, presence: true
  validates :notes, length: { maximum: 255 }, allow_blank: true
  validate :box_is_in_same_house_as_item
  validate :room_is_in_same_house_as_item

  private

  def box_is_in_same_house_as_item
    return unless box
    return if box&.house == house

    errors.add(:box, 'must be in the same house as the item')
  end

  def room_is_in_same_house_as_item
    return if room&.house == house

    errors.add(:room, 'must be in the same house as the item')
  end

  def purge_image
    image.purge
  end
end
