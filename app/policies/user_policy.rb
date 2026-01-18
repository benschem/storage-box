# frozen_string_literal: true

# Restrict who can create, update, destroy users
class UserPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    acting_on_self?
  end

  def destroy?
    acting_on_self?
  end

  # Users can see all other users (when inviting to house)
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope
      # TODO: in future, restrict scope:
      # - users who have verified their email (or maybe not?)
      # - users who are not blocked/blocking the other user
      # - users who are not deleted
    end
  end

  private

  def acting_on_self?
    record == user
  end
end
