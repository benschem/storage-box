class Item < ApplicationRecord
  include PgSearch::Model

  belongs_to :box
  has_and_belongs_to_many :tags

  has_one_attached :image

  validates :name, presence: true

  pg_search_scope :search_by_text,
  against: [
    [:name, 'A'],           # Highest weight
    [:description, 'C']     # Lower weight
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

  def self.search(query)
    if query.length <= 1
      joins("LEFT JOIN items_tags ON items.id = items_tags.item_id")
        .joins("LEFT JOIN tags ON tags.id = items_tags.tag_id")
        .where(
          "items.name ILIKE :q OR items.description ILIKE :q OR tags.name ILIKE :q",
          q: "%#{query}%"
        ).distinct
    else
      Item.includes(:tags).search_by_text(query)
    end
  end
end
