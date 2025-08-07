# frozen_string_literal: true

# Restrict who can create and update invite
class InvitePolicy < ApplicationPolicy
  def create?
    record.sender == user && user.houses.include?(record.house)
  end

  def update?
    record.recipient == user && record.status == 'pending'
  end

  # 
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(house_id: user.house_ids).includes(:house)
    end
  end
end
