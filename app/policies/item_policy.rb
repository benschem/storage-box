# frozen_string_literal: true

# Any signed in user can create an item
# Users can only update and destroy items in houses they're a member of
class ItemPolicy < ApplicationPolicy
  def show?
    signed_in_user? && item_in_user_house?
  end

  def create?
    signed_in_user?
  end

  def update?
    signed_in_user? && item_in_user_house?
  end

  def destroy?
    signed_in_user? && item_in_user_house?
    # TODO: figure out who should be able to destroy an item
    # Is it the user who created the item?
    # Is it the house admin?
    # Is it permission based?
    # Right now it's just anyone in the house
  end

  # Users can see items in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope.where(house_id: user.house_ids)
    end
  end

  def item_in_user_house?
    user.houses&.include?(record.house)
  end
end
