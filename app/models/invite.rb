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
  before_create :try_to_set_invitee
  before_create :set_expiry_timestamp

  after_create_commit :schedule_expiry_job
  after_create_commit :notify_invitee

  def accept_and_join_house!
    transaction do
      update!(status: :accepted)
      house.users << invitee unless house.users.include?(invitee)
      notify_inviter_of_acceptance
    end
  end

  def decline_invite!
    update!(status: :declined)
  end

  private

  def notify_invitee
    if User.exists?(email: invitee_email)
      notify_invitee
    else
      queue_invite_email
    end
  end

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_expiry_timestamp
    self.expires_on = 2.days.from_now
  end

  def schedule_expiry_job
    MarkInviteAsExpiredJob.set(wait_until: self.expires_on + 1.minute).perform_later(self)
  end

  def try_to_set_invitee
    if self.invitee.nil? && self.invitee_email.present?
      invitee_user = User.find_by(email: self.invitee_email)
      self.invitee = invitee_user if invitee_user
    end
  end

  def notify_invitee
      broadcast_append_to "user_#{invitee.id}_invites",
                          partial: "invites/invite",
                          target: "notifications",
                          locals: { invite: self }


  end

  def queue_invite_email
    # Send email asking to signup
    # InviteMailer.with(invite: self).invite_email.deliver_later
    # User gets notified upon account creation via callback in User model
  end

  def notify_inviter_of_acceptance
    broadcast_append_to "user_#{inviter.id}_invites",
                        partial: "invites/invite_accepted",
                        target: "notifications",
                        locals: { invite: self }
  end
end
