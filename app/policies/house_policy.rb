# frozen_string_literal: true

# Any signed in user can create a house
# Users can only update and destroy houses they belong to
class HousePolicy < ApplicationPolicy
  def create?
    signed_in_user?
  end

  def update?
    signed_in_user? && member_of_house?
  end

  def destroy?
    signed_in_user? && member_of_house?
    # TODO: figure out who should be able to destroy a house
    # Is it the user who created the box?
    # Is it the house admin?
    # Is it permission based?
    # Right now it's just anyone in the house
  end

  # Users can see houses they created and houses they are members of
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope.where(id: user.house_ids)
    end
  end

  private

  def member_of_house?
    user.houses&.include?(record)
  end
end
