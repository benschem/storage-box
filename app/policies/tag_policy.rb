class TagPolicy < ApplicationPolicy
  def create?
    user.present?
    # TODO: && user.permissions.include?(:create) need to implement something
  end

  def update?
    user_shares_house_with_tag_creator?
    # TODO: && user.permissions.include?(:update) need to implement something
  end

  def remove?
    user_shares_house_with_tag_creator?
    # TODO: && user.permissions.include?(:destroy) need to implement something
  end

  def destroy?
    user_shares_house_with_tag_creator?
    # TODO: && user.permissions.include?(:destroy) need to implement something
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      houses_user_belongs_to = user.houses.select(:id)

      connected_user_ids = User.joins(:houses).where(houses: { id: houses_user_belongs_to }).distinct.pluck(:id)

      scope.where(user_id: connected_user_ids)
    end
  end
end

private

def user_shares_house_with_tag_creator?
  houses_user_belongs_to = user.houses.pluck(:id)
  houses_tag_creator_belongs_to = record.user.houses.pluck(:id)

  (houses_user_belongs_to & houses_tag_creator_belongs_to).any?
end
