class RoomPolicy < ApplicationPolicy
  def show?
    @user.rooms.include?(@record)
    # TODO: && @user.permissions.include?(:show) need to implement something
  end

  def create?
    true
    # @user.rooms.include?(@record)
    # TODO: && @user.permissions.include?(:create) need to implement something
  end

  def update?
    @user.rooms.include?(@record)
    # TODO: && @user.permissions.include?(:update) need to implement something
  end

  def destroy?
    @user.rooms.include?(@record)
    # TODO: && @user.permissions.include?(:destroy) need to implement something
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      @user.rooms
    end
  end
end
