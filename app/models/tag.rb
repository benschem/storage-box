class Tag < ApplicationRecord
  has_and_belongs_to_many :boxes

  validates :name, presence: true
end
