class Box < ApplicationRecord
  belongs_to :house
  belongs_to :room, counter_cache: true
  has_many :items

  before_validation :set_number, on: :create
  validates :number, presence: true, numericality: { only_integer: true }
  validates :number, uniqueness: { scope: :house_id }

  private

  def set_number
    highest_number_in_house = house&.boxes&.maximum(:number) || 0
    self.number ||= highest_number_in_house + 1
  end
end
