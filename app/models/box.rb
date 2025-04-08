class Box < ApplicationRecord
  belongs_to :room

  before_validation :set_number, on: :create

  validates :number, presence: true, uniqueness: true, numericality: { only_integer: true }

  private

  def set_number
    self.number ||= Box.where(user_id: user_id).maximum(:number).to_i + 1
  end
end
