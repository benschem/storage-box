# frozen_string_literal: true

# A label on an item
class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :items, through: :taggings

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
