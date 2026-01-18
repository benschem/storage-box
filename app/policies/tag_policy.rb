# frozen_string_literal: true

# # Tags are global - one tag attaches to multiple items
class TagPolicy < ApplicationPolicy
  def create?
    signed_in_user?
  end

  # Tags cannot be updated or destroyed.
  # Renaming a tag requires creating a new tag.
  def update?
    false
  end

  def destroy?
    false
  end

  # Users can only see tags on items in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope
        .joins(:taggings)
        .joins(:items)
        .where(items: { house_id: user.house_ids })
        .distinct
    end
  end
end
