class BoxPolicy < ApplicationPolicy
  def show?
    user.houses.include?(record.house)
    # TODO: && user.permissions.include?(:show) need to implement something
  end

  def create?
    user.present?
    # TODO: && user.permissions.include?(:create) need to implement something
  end

  def update?
    user.houses.include?(record.house)
    # TODO: && user.permissions.include?(:update) need to implement something
  end

  def destroy?
    user.houses.include?(record.house)
    # TODO: && user.permissions.include?(:destroy) need to implement something
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(room: :house).where(houses: { id: user.house_ids })
    end
  end
end
