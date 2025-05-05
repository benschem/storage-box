class Item < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  belongs_to :house
  belongs_to :room, optional: true
  belongs_to :box, optional: true
  has_and_belongs_to_many :tags, optional: true

  has_one_attached :image
  attr_accessor :remove_image
  after_save :purge_image, if: -> { remove_image == "1" }

  validates :name, presence: true
  validates :notes, length: { maximum: 255 }, allow_blank: true
  validate :box_or_room_present

  scope :search, ->(query) {
    return none if query.blank?

    query = query.strip[0..100]

    if query.length <= 2
      joins("LEFT JOIN items_tags ON items.id = items_tags.item_id")
        .joins("LEFT JOIN tags ON tags.id = items_tags.tag_id")
        .where(
          "items.name ILIKE :q OR items.notes ILIKE :q OR tags.name ILIKE :q",
          q: "%#{query}%"
        ).distinct
    else
      includes(:tags).search_by_text(query)
    end
  }

  pg_search_scope :search_by_text,
  against: [
    [:name, 'A'],           # Highest weight
    [:notes, 'C']     # Lower weight
  ],
  associated_against: {
    tags: [:name]           # Default weight is B for associated
  },
  using: {
    tsearch: {
      prefix: true,         # Allows partial word matching
      dictionary: 'english',
      tsvector_column: nil, # We're generating the vector on the fly
      normalization: 2,     # Accounts for word frequency
      any_word: true
    },
    trigram: {}
  },
  ranked_by: ":tsearch + (0.5 * :trigram)"

  private

  def box_or_room_present
    if box_id.blank? && room_id.blank?
      errors.add(:base, "Item must be in either a box or a room")
    elsif box_id.present? && room_id.present?
      errors.add(:base, "Item can be in a box only or a room only, not both")
    end
  end

  def purge_image
    image.purge
  end
end
