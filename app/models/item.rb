class Item < ApplicationRecord
  belongs_to :box

  validates :name, presence: true
end
