# frozen_string_literal: true

# Users can add or remove a tag on items in their house
class TaggingPolicy < ApplicationPolicy
  # "Add" a tag to an item
  def create?
    signed_in_user? && tagged_item_in_user_house?
  end

  # "Remove" a tag from an item
  def destroy?
    signed_in_user? && tagged_item_in_user_house?
    # TODO: figure out who should be able to remove a tag
    # Is it the user who added the tag?
    # Is it the user who created the item?
    # Is it the house admin?
    # Is it permission based?
    # Right now it's just anyone in the house
  end

  # Users can only see tags on items in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope
        .joins(:item)
        .where(items: { house_id: user.house_ids })
        .distinct
    end
  end

  private

  def tagged_item_in_user_house?
    user.houses&.include?(record.item.house)
  end
end
