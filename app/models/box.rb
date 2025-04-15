class Box < ApplicationRecord
  belongs_to :room
  has_many :items

  before_validation :set_number, on: :create

  validates :number, presence: true, numericality: { only_integer: true }
  validate :unique_number_within_house

  def padded_number
    total_boxes = Box.joins(room: :house)
                     .where(rooms: { house_id: room.house.id })
                     .count

    padding_length = total_boxes.to_s.length
    number.to_s.rjust(padding_length, '0')
  end

  private

  def set_number
    self.number ||= self.room.house.boxes.maximum(:number).to_i + 1
  end

  def unique_number_within_house
    if room && room.house.boxes.where(number: number).exists?
      errors.add(:number, "must be unique within the house")
    end
  end
end
