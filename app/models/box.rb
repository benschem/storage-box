class Box < ApplicationRecord
  belongs_to :room
  has_many :items

  before_validation :set_number, on: :create

  validates :number, presence: true, numericality: { only_integer: true }
  validate :unique_number_within_house

  def house
    self.room.house
  end

  private

  def set_number
    self.number ||= self&.house&.boxes.maximum(:number).to_i + 1
  end

  def unique_number_within_house
    if room && room.house.boxes.where(number: number).exists?
      errors.add(:number, "must be unique within the house")
    end
  end
end
