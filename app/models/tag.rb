class Tag < ApplicationRecord
  belongs_to :house
  has_and_belongs_to_many :items

  validates :name, presence: true
  validates :name, uniqueness: { scope: :house_id }
end

# Should this kinda thing go in a filtering concern and not on the tag model?
#
#
# it 'users can only see items tagged with a tag if they belong to a house that the tagged item belongs to'
# it 'returns tagged items only from houses the user belongs to'
# it 'does not return tagged items from houses the user is not a member of'
# it 'includes tagged items from houses the user is a member of'
# it 'excludes tagged items from other houses'
#
# it 'users can filter items by tag across all houses they are members of, without needing to select a specific house.' do
#   # expect filter by fragile to return items in house A if the user is in house A
#   # expect filter by fragile to return items in house B if the user is in house B
#   # expect filter by fragile to not eturn items in house C if the user is not in house C
# it 'returns tagged items from multiple houses the user belongs to'
# it 'does not require a specific house to be selected when filtering by tag'
# end
#
# TODO: extract these tests out as spec for `app/queries/item_tag_filter.rb`
#
# Create a chainable query object, eg:
#
#   class ItemTagFilter
#     def initialize(scope: Item.all, tag_name:, user:)
#       @scope = scope
#       @tag_name = tag_name
#       @user = user
#     end
#
#     def call
#       @scope.joins(:tags)
#             .where(tags: { name: @tag_name, house_id: @user.house_ids })
#             .distinct
#     end
#   end`
#
# Then you can do:
#
# filtered_items = ItemTagFilter.new(tag_name: 'fragile', user: current_user).call
# filtered_items.order(:created_at).limit(10)
#
# OR
#
# ItemTagFilter.new(scope: Item.where(category: 'furniture'), tag_name: 'fragile', user: current_user).call
