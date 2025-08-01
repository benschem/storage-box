# frozen_string_literal: true

# Represents a user of the application.
# A user is someone who is looking to catalogue their personal belongings.
class User < ApplicationRecord
  include ValidatePassword
  include Invitable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :houses # optional: true is the default for has_and_belongs_to_many
  has_many :rooms, through: :houses # TODO: Does it need this?
  has_many :boxes, through: :rooms # TODO: Does it need this?

  # TODO: come back to this and add options for the user
  # to transfer their items to a house or fully delete them.
  has_many :items, dependent: :restrict_with_error

  validates :name, presence: true
end
