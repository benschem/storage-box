# frozen_string_literal: true

# Joins a Tag and an Item
class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :item

  validates :tag_id, uniqueness: { scope: :item_id }

  after_destroy :cleanup_orphaned_tag

  private

  def cleanup_orphaned_tag
    tag.destroy! if tag.items.empty?
  end
end
