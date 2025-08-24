class ItemPolicy < ApplicationPolicy
  def show?
    user.houses.include?(record.house)
  end

  def create?
    user.present?
  end

  def update?
    user.houses.include?(record.house)
  end

  def destroy?
    user.houses.include?(record.house)
  end

  # Users can see items in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(house_id: user.house_ids)
    end
  end
end
