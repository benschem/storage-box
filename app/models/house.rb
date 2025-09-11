# frozen_string_literal: true

# A house with rooms where items are stored
class House < ApplicationRecord
  # TODO: Replace HABTM with Memberships join table
  # https://chatgpt.com/share/68c2b7b2-89f0-8004-91a0-c78b652e24da
  has_and_belongs_to_many :users
  has_many :rooms, dependent: :restrict_with_error
  has_many :boxes, through: :rooms
  has_many :items, dependent: :restrict_with_error
  has_many :invites, dependent: :destroy

  validates :name, presence: true
end
