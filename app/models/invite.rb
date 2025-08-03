# frozen_string_literal: true

# Represents an Invitation from a User (the inviter) inviting another User (the invitee) to join a House they belong to.
#
# TODO: If invite is declined it should not be deleted and prevent future invites from user?
# TODO: Consider blocking?
class Invite < ApplicationRecord
  include InviteNotifier

  DAYS_VALID = 3.days

  belongs_to :house

  belongs_to :inviter,
             class_name: 'User',
             inverse_of: :sent_invites

  belongs_to :invitee,
             class_name: 'User',
             optional: true,
             inverse_of: :received_invites

  enum :status, { pending: 'pending', accepted: 'accepted', declined: 'declined', expired: 'expired' }

  before_validation :set_expiry_time
  before_validation :generate_url_token
  before_validation { format_invitee_email }

  validates :invitee_email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
  validate :inviter_must_belong_to_house

  before_create :assign_invitee_if_email_registered

  after_create_commit :schedule_expiration

  def overdue?
    expires_on.past? && update(status: 'expired')
  end

  private

  def format_invitee_email
    self.invitee_email = invitee_email.downcase.strip if invitee_email.present?
  end

  def set_expiry_time
    self.expires_on ||= DAYS_VALID.from_now
  end

  def generate_url_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def inviter_must_belong_to_house
    return if house.blank? || inviter.blank?
    return if house.users.exists?(id: inviter_id)

    errors.add(:inviter, 'must be a member of the house')
  end

  def assign_invitee_if_email_registered
    return if invitee_email.blank? || invitee.present?

    self.invitee = User.find_by(email: invitee_email)
  end

  def schedule_expiration
    MarkInviteAsExpiredJob.set(wait_until: expires_on + 1.minute).perform_later(self)
  end
end
