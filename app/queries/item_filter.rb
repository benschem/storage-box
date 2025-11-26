# frozen_string_literal: true

## This class is an abstraction of “apply a bunch of named scopes to a given list of items.
#
## Filters can be applied to the items all at once, like so:
#
#    @items = ItemFilter.apply(filters: { filter_by_house: 48 }, items: Item.all )
#
## Arguments:
# - filters: a Hash of filters and their values
# - items: an ActiveRecord::Relation of Items that the filters will be applied to
#
## How it works:
# - for each of the allowed filters,
#   - it checks if any filter values were given for it
#     - if so, it looks up the appropriate scope and calls that scope on the items
#     - it passes the returned items to the next iteration of the loop, to check the next allowed filter
#   - or if no values were given
#     - it passes the unchanged items to the next iteration of the loop, to check the next allowed filter
# - then it sorts the items according to the given params, or falls back to a default
#
## Returns:
# - a filtered ActiveRecord::Relation.
class ItemFilter
  class ScopeNotImplemented < StandardError; end

  # FILTERS = {

  #   houses: :in_house, true],
  #   rooms: [:in_room, true],
  #   unboxed: [:unboxed, false],
  #   boxed: [:boxed, false],
  #   boxes: [:in_box, true],
  #   any_tags: [:with_any_of_these_tags, true],
  #   all_tags: [:with_all_of_these_tags, true]
  # }.freeze

  SORT_COLUMNS = %w[name created_at updated_at].freeze
  SORT_DIRECTIONS = %w[asc desc].freeze

  def initialize(filters:, items:)
    @filters = filters
    @items = items
    @logger = Rails.logger

    @houses = filters[:houses]
    @rooms = filters[:rooms]
    @boxes = filters[:boxes]
    @tags = filters[:tags]
  end

  def self.apply(**)
    new(**).apply
  end

  def apply
    filtered_items = apply_filters
    column, direction = sort_params

    filtered_items&.sorted(column, direction)
  end

  private

  attr_reader :logger

  def any_tags?
    @any_tags ||= @filters[:tag_mode] == 'any_tags'
  end

  def all_tags?
    @all_tags ||= @filters[:tag_mode] == 'all_tags'
  end

  def apply_filters
    housed = @items.in_houses(@houses)
    roomed = housed.in_rooms(@rooms)
    boxed = roomed.in_boxes(@boxes)

    if any_tags?
      tagged = boxed.with_any_of_these_tags(@tags)
    elsif all_tags?
      tagged = boxed.with_all_of_these_tags(@tags)
    end

    tagged.presence || boxed
  end

  def sort_params
    column = @filters[:sort_by]
    direction = @filters[:sort_direction]

    return %i[updated_at desc] unless valid?(column, direction)

    [column, direction]
  end

  def valid?(column, direction)
    SORT_COLUMNS.include?(column) && SORT_DIRECTIONS.include?(direction)
  end
end
