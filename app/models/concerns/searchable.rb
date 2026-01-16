# frozen_string_literal: true

# Search items by name, notes, or tag
module Searchable
  extend ActiveSupport::Concern

  include PgSearch::Model

  included do # rubocop:disable Metrics/BlockLength
    scope :search, lambda { |query|
      return none if query.blank?

      query = query.strip[0..100]

      if query.length <= 2
        joins('LEFT JOIN taggings ON items.id = taggings.item_id')
          .joins('LEFT JOIN tags ON tags.id = taggings.tag_id')
          .where(
            'items.name ILIKE :q OR items.notes ILIKE :q OR tags.name ILIKE :q',
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
                    ranked_by: ':tsearch + (0.5 * :trigram)'
  end
end
