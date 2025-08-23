# frozen_string_literal: true

# A tag reprsents a label attached to items
# Tags are global - they can be associated with, or removed from, items, but
# cannot be updated or destroyed. Renaming a tag requires creating a new tag.
class TagPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def remove?
    user && in_same_house?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  private

  def in_same_house?
    record.items.joins(:house).exists?(house_id: user.house_ids)
  end

  # Users can see tags on items in houses they belong to
  class Scope < ApplicationPolicy::Scope
    def resolve
      Tag.joins(:items).where(items: { house_id: user.house_ids }).distinct
    end
  end
end
