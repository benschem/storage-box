class InvitePolicy < ApplicationPolicy
  def create?
    user.houses.include?(record.house) && record.inviter == user
  end

  def update?
    user.houses.include?(record.house) &&
      record.invitee == user &&
      record.status == 'pending'
  end

  def accept?
    user == record.invitee && record.status == 'pending'
  end


  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(house_id: user.house_ids).includes(:house)
    end
  end
end
