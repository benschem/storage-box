# frozen_string_literal: true

# Filter items by tags
module TagFilterable
  extend ActiveSupport::Concern

  class_methods do
    def with_any_of_these_tags(tags)
      joins(:tags).where(tags: { id: resolve_tag_ids(Array(tags)) }).distinct
    end

    def with_all_of_these_tags(tags)
      joins(:tags)
        .where(tags: { id: resolve_tag_ids(Array(tags)) })
        .group(:id)
        .having('COUNT(DISTINCT tags.id) = ?', Array(tags).size)
    end

    private

    def resolve_tag_ids(tags)
      tag_ids_by_name = Tag.where(name: tags.grep(String)).pluck(:name, :id).to_h

      tags.filter_map do |tag|
        case tag
        when Tag then tag.id
        when Integer then tag
        when String then tag_ids_by_name[tag]
        else
          raise ArgumentError, "Expected Tag objects, tag ID integers, or tag name strings, but got: #{tag.inspect}"
        end
      end.uniq
    end
  end
end
