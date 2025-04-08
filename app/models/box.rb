class Box < ApplicationRecord
  belongs_to :room
  has_many :items
  has_and_belongs_to_many :tags

  before_validation :set_number, on: :create

  validates :number, presence: true, numericality: { only_integer: true }
  validate :unique_number_within_household

  private

  def set_number
    self.number ||= self.room.household.boxes.maximum(:number).to_i + 1
  end

  def unique_number_within_household
    if room && room.household.boxes.where(number: number).exists?
      errors.add(:number, "must be unique within the household")
    end
  end
end
