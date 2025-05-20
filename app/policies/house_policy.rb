class HousePolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    user.houses.include?(record)
  end

  def destroy?
    user.houses.include?(record)
  end
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user.houses.select(:id))
    end
  end
end
