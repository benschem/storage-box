class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :houses, optional: true
  has_many :items
  has_many :rooms, through: :houses
  has_many :boxes, through: :rooms
  has_many :tags

  has_many :sent_invites, class_name: 'Invite', foreign_key: 'inviter_id'
  has_many :received_invites, class_name: 'Invite', foreign_key: 'invitee_id'

  validates :name, presence: true

  after_create_commit :check_for_house_invites

  # validate :password_complexity

  private

  # def password_complexity
  #   if password.present? and !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{12,}$/)
  #     errors.add :password, "must include at least one lowercase letter, one uppercase letter, one digit, and needs to be minimum 12 characters."
  #   end
  # end

  def check_for_house_invites
    house_invites = Invite.where(invitee_email: self.email)
    return unless house_invites.present?

    house_invites.each do |house_invite|
      house_invite.update(invitee: self)
      NotifyUserOfNewHouseInvite.perform_later(house_invite)
    end
  end
end
