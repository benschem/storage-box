# frozen_string_literal: true

# Represents a user of the application, someone who is looking to catalogue their personal belongings.
class User < ApplicationRecord
  include ValidatePassword
  include Invitable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # TODO: Replace HABTM with Memberships join table
  # https://chatgpt.com/share/68c2b7b2-89f0-8004-91a0-c78b652e24da
  has_and_belongs_to_many :houses # optional: true is the default for has_and_belongs_to_many

  # TODO: come back to this and add options for the user
  # to transfer their items to a house or fully delete them.
  has_many :items, dependent: :restrict_with_error

  validates :name, presence: true

  def give_items_away(items:, user:)
    # This is only for when users are about to delete their account, so it's ok to skip validations.
    own_item_ids = self.items.where(id: items.map(&:id)).pluck(:id)
    Item.where(id: own_item_ids).update_all(user_id: user.id) # rubocop:disable Rails/SkipsModelValidations
  end
end
