# frozen_string_literal: true

# Users must be in the same house as the box
class BoxPolicy < ApplicationPolicy
  def show?
    signed_in_user? && box_in_user_house?
  end

  def create?
    signed_in_user? && box_in_user_house?
  end

  def update?
    signed_in_user? && box_in_user_house?
  end

  def destroy?
    signed_in_user? && box_in_user_house?
    # TODO: figure out who should be able to destroy a box
    # Is it the user who created the box?
    # Is it the house admin?
    # Is it permission based?
    # Right now it's just anyone in the house
  end

  # Users can see boxes in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope.where(house_id: user.house_ids)
    end
  end

  def box_in_user_house?
    user.houses&.include?(record.house)
  end
end
