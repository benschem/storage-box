# frozen_string_literal: true

## This Filter class is an abstraction of “apply a bunch of named scopes to a given relation.
#
## Filters can be applied to an ActiveRecord::Relation all at once, like so:
#
#    @items = Filter.apply(filters: { filter_by_house: 48 }, to: Item.all )
#
## Arguments:
# - filters: a Hash of filters and their values
# - to: an ActiveRecord::Relation that the filters will be applied to
#
## How it works:
# - Filter checks which model the Relation belongs to
# - for each of the given filters,
#   - it asks the Relations class for the matching scope
#   - if the filter matches a scope, and the class has that scope, it calls that scope on the Relation
#   - and passes the returned Relation to the next iteration of the loop
#   - or if none match, it passes the unchanged Relation to the next iteration of the loop
#
## Returns:
# - a filtered ActiveRecord::Relation.
class Filter
  SCOPES_BY_FILTER = {
    filter_by_house: :in_house,
    filter_by_room: :in_room,
    filter_by_box: :in_box,
    filter_all_boxed: :boxed,
    filter_all_unboxed: :unboxed,
    filter_by_any_tag: :with_any_of_these_tags,
    filter_by_all_tags: :with_all_of_these_tags
  }.freeze

  def initialize(filters:, to:)
    @filters = filters
    @initial_relation = to
  end

  def self.apply(**)
    new(**).apply
  end

  def apply
    @filters.reduce(@initial_relation) do |filtered_relation, (filter, value)|
      scope = SCOPES_BY_FILTER[filter]

      apply_scope(scope, value, filtered_relation, filter)
    end
  end

  private

  def apply_scope(scope, value, filtered_relation, filter)
    unless scope
      Rails.logger.debug { "#{@initial_relation.klass} does not respond to #{scope}" }
      return filtered_relation
    end

    unless filtered_relation.respond_to?(scope)
      Rails.logger.debug { "#{filter} is not a valid filter" }
      return filtered_relation
    end

    filtered_relation.public_send(scope, *Array(value))
  end
end
