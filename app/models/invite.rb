class Invite < ApplicationRecord
  belongs_to :house
  belongs_to :inviter, class_name: 'User'
  belongs_to :invitee, class_name: 'User', optional: true

  enum status: { pending: 'pending', accepted: 'accepted', declined: 'declined', expired: 'expired' }

  before_validation { self.invitee_email = invitee_email.downcase.strip if invitee_email.present? }

  validates :house, presence: true
  validates :inviter, presence: true
  validates :invitee_email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true

  before_create :generate_token
  after_create_commit :set_expiry
  after_create_commit :try_to_set_invitee

  after_create_commit :invite_invitee
  after_update_commit :notify_inviter, if: -> { status == "accepted" }

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_expiry
    self.expires_on = 2.days.from_now
    MarkInviteAsExpiredJob.set(wait_until: self.expires_on + 1.minute).perform_later(self)
  end

  def try_to_set_invitee
    if self.invitee.nil? && self.invitee_email.present?
      self.invitee = User.find_by(email: self.invitee_email)
    end
  end

  def invite_invitee
    user_exists =  User.find_by(email: invitee_email).present?

    if user_exists
      NotifyUserOfNewHouseInvite.perform_later(self)
    else
      # Send email asking to signup
      # InviteMailer.with(invite: self).invite_email.deliver_later
      # User gets notified upon account creation via callback in User model
    end
  end

  def notify_inviter
    NotifyUserOfAcceptedHouseInviteJob.perform_later(self)
  end
end
