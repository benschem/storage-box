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
    filter_by_tag: :with_any_of_these_tags
    # filter_by_all_tags: :with_all_of_these_tags
  }.freeze

  def initialize(filters:, to:)
    @filters = filters
    @initial_relation = to
    @logger = Rails.logger
  end

  def self.apply(**)
    new(**).apply
  end

  def apply
    @filters.reduce(@initial_relation) do |filtered_relation, (filter, values)|
      next filtered_relation if values.blank?

      scope = lookup_scope(filter)

      next filtered_relation unless scope
      next filtered_relation unless valid_scope?(scope, filtered_relation)

      filtered_relation.public_send(scope, *Array(values))
    end
  end

  private

  attr_reader :logger

  def lookup_scope(filter)
    scope = SCOPES_BY_FILTER[filter.to_sym]
    logger.warn { "#{filter} is not a valid filter" } unless scope
    scope&.to_sym
  end

  def valid_scope?(scope, relation)
    valid = relation.respond_to?(scope&.to_sym)
    logger.warn { "#{relation.klass} does not respond to #{scope.inspect}" } unless valid
    valid
  end
end
