class InvitePolicy < ApplicationPolicy
  def create?
    record.inviter == user && user.houses.include?(record.house)
  end

  def update?
    record.invitee == user && record.status == 'pending'
  end
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(house_id: user.house_ids).includes(:house)
    end
  end
end
