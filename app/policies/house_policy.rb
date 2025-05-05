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
      scope
        .joins(:users)
        .where(users: { id: user.id })
        .distinct
    end
  end
end
