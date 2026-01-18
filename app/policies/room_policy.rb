# frozen_string_literal: true

# Users must belong to the house the room is in
class RoomPolicy < ApplicationPolicy
  def show?
    signed_in_user? && room_in_user_house?
  end

  def create?
    signed_in_user? && room_in_user_house?
  end

  def update?
    signed_in_user? && room_in_user_house?
  end

  def destroy?
    signed_in_user? && room_in_user_house?
    # TODO: figure out who should be able to destroy a room
    # Is it the user who created the room?
    # Is it the house admin?
    # Is it permission based?
    # Right now it's just anyone in the house
  end

  # Users can see rooms in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope.where(house_id: user.house_ids)
    end
  end

  def room_in_user_house?
    user.houses.include?(record.house)
  end
end
