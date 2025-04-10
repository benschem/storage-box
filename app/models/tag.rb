class Tag < ApplicationRecord
  has_and_belongs_to_many :boxes
  belongs_to :household

  validates :name, presence: true
end
