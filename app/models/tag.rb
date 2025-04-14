class Tag < ApplicationRecord
  has_and_belongs_to_many :boxes
  belongs_to :house

  validates :name, presence: true
end
