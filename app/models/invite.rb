# frozen_string_literal: true

# Represents an Invitation
# - from a User (the inviter)
# - inviting another User (the invitee)
# - to join a House they belong to.
#
# The invitee may or may not already be a User of the app.
# - if they are, they get pushed their invitation in-app.
# - if they are not, they get emailed their invitiation.
#
# The invitee may accept or decline the application
# - if they accept, the inviter is notified.
# - if they decline, the inviter is not notified.
#
# An Invitation expires.
# An Invitation ensures that only the user invited can accept.
#
class Invite < ApplicationRecord
  belongs_to :house

  belongs_to :inviter,
             class_name: 'User',
             inverse_of: :sent_invites

  belongs_to :invitee,
             class_name: 'User',
             optional: true,
             inverse_of: :received_invites

  enum :status, { pending: 'pending', accepted: 'accepted', declined: 'declined', expired: 'expired' }

  before_validation { downcase_strip_invitee_email }
  validates :invitee_email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true

  before_create :set_expiry_timestamp
  before_create :generate_url_token
  before_create :set_invitee

  after_create_commit :notify_invitee
  after_create_commit :schedule_expiry

  private

  def downcase_strip_invitee_email
    self.invitee_email = invitee_email.downcase.strip if invitee_email.present?
  end

  def generate_url_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_invitee
    return false if invitee.present? || invitee_email.blank?

    self.invitee = User.find_by(email: invitee_email)
  end

  def set_expiry_timestamp
    self.expires_on = 2.days.from_now
  end

  def notify_invitee
    if invitee
      notify_in_app
    else
      queue_invite_email
    end
  end

  def schedule_expiry
    MarkInviteAsExpiredJob.set(wait_until: expires_on + 1.minute).perform_later(self)
  end

  def notify_in_app
    broadcast_append_to "user_#{invitee.id}_invites",
                        partial: 'invites/invite',
                        target: 'notifications',
                        locals: { invite: self }
  end

  def queue_invite_email
    # Send email asking to signup
    # InviteMailer.with(invite: self).invite_email.deliver_later
    # User gets notified upon account creation via callback in User model
  end

  def notify_inviter_of_acceptance
    broadcast_append_to "user_#{inviter.id}_invites",
                        partial: 'invites/invite_accepted',
                        target: 'notifications',
                        locals: { invite: self }
  end
end
