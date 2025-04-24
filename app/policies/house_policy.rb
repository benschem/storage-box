class HousePolicy < ApplicationPolicy
  def show?

  end

  def create?

  end

  def update?

  end

  def destroy?

  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      @user.houses
    end
  end
end
