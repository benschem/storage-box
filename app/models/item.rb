class Item < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  belongs_to :house, counter_cache: true
  belongs_to :room
  belongs_to :box, optional: true
  has_and_belongs_to_many :tags, optional: true

  has_one_attached :image
  attr_accessor :remove_image
  after_save :purge_image, if: -> { remove_image == "1" }

  validates :name, presence: true
  validates :notes, length: { maximum: 255 }, allow_blank: true
  validate :box_is_in_same_house_as_item
  validate :room_is_in_same_house_as_item

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
                    [:name, 'A'], # Highest weight
                    [:notes, 'C'] # Lower weight
                  ],
                  associated_against: {
                    tags: [:name] # Default weight is B for associated
                  },
                  using: {
                    tsearch: {
                      prefix: true, # Allows partial word matching
                      dictionary: 'english',
                      tsvector_column: nil, # We're generating the vector on the fly
                      normalization: 2, # Accounts for word frequency
                      any_word: true
                    },
                    trigram: {}
                  },
                  ranked_by: ":tsearch + (0.5 * :trigram)"

  private

  def box_is_in_same_house_as_item
    return unless box

    if box.house != house
      errors.add(:box, "must be in the same house as the item")
    end
  end

  def room_is_in_same_house_as_item
    return unless room

    if room.house != house
      errors.add(:room, "must be in the same house as the item")
    end
  end

  def purge_image
    image.purge
  end
end
