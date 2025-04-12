class Box < ApplicationRecord
  belongs_to :room
  has_many :items
  has_and_belongs_to_many :tags

  before_validation :set_number, on: :create

  validates :number, presence: true, numericality: { only_integer: true }
  validate :unique_number_within_household

  def padded_number(household)
    total_boxes = Box.joins(room: :household)
                     .where(rooms: { household_id: room.household.id })
                     .count

    padding_length = total_boxes.to_s.length
    number.to_s.rjust(padding_length, '0')
  end

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
