# frozen_string_literal: true

## This class is an abstraction of “apply a bunch of named scopes to a given list of items.
#
## Filters can be applied to the items all at once, like so:
#
#    @items = ItemFilter.apply(filters: { filter_by_house: 48 }, to: Item.all )
#
## Arguments:
# - filters: a Hash of filters and their values
# - to: an ActiveRecord::Relation of Items that the filters will be applied to
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

  FILTERS = {
    # filter_param: [:scope_name, takes_args?]
    houses: [:in_house, true],
    rooms: [:in_room, true],
    unboxed: [:unboxed, false],
    boxed: [:boxed, false],
    boxes: [:in_box, true],
    any_tags: [:with_any_of_these_tags, true],
    all_tags: [:with_all_of_these_tags, true]
  }.freeze

  SORT_COLUMNS = %w[name created_at updated_at].freeze
  SORT_DIRECTIONS = %w[asc desc].freeze

  def initialize(filters:, to:)
    @filter_params = filters
    @initial_relation = to
    @logger = Rails.logger
  end

  def self.apply(**)
    new(**).apply
  end

  def apply
    filtered = apply_filters

    column, direction = sort_params

    filtered.sorted(column, direction)
  end

  private

  attr_reader :logger

  def apply_filters
    FILTERS.reduce(@initial_relation) do |filtered_relation, (filter_name, (scope, takes_args))|
      values = @filter_params[filter_name.to_sym]

      next filtered_relation if values.blank?
      raise ScopeNotImplemented "#{filtered_relation.klass} :#{scope}" unless filtered_relation.respond_to?(scope)

      if takes_args
        filtered_relation.public_send(scope, *Array(values))
      else
        filtered_relation.public_send(scope)
      end
    end
  end

  def sort_params
    column = @filter_params[:sort_by]
    direction = @filter_params[:sort_direction]

    return %i[updated_at desc] unless valid?(column, direction)

    [column, direction]
  end

  def valid?(column, direction)
    SORT_COLUMNS.include?(column) && SORT_DIRECTIONS.include?(direction)
  end
end
