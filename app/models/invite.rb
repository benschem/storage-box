# frozen_string_literal: true

# Invitation from a User (the sender) inviting another User (the recipient) to join a House they belong to.
#
# TODO: If invite is declined it should not be deleted and prevent future invites from user?
# TODO: Consider blocking?
class Invite < ApplicationRecord
  include InviteNotifier

  DAYS_VALID = 3.days

  belongs_to :house

  belongs_to :sender,
             class_name: 'User',
             inverse_of: :sent_invites

  belongs_to :recipient,
             class_name: 'User',
             optional: true,
             inverse_of: :received_invites

  enum :status, { pending: 'pending', accepted: 'accepted', declined: 'declined', expired: 'expired' }

  before_validation :set_expiry_time, on: :create
  before_validation :set_token, on: :create
  before_validation { format_recipient_email }

  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
  validate :sender_must_belong_to_house

  before_create :assign_recipient_if_email_registered

  after_create_commit :schedule_expiration

  def overdue?
    expires_on.past? && update(status: 'expired')
  end

  private

  def format_recipient_email
    self.recipient_email = recipient_email.downcase.strip if recipient_email.present?
  end

  def set_expiry_time
    self.expires_on ||= DAYS_VALID.from_now
  end

  def set_token
    self.token ||= generate_unique_token
  end

  def generate_unique_token
    token = SecureRandom.urlsafe_base64(24)
    token = SecureRandom.urlsafe_base64(24) while Invite.exists?(token: token)
    token
  end

  def sender_must_belong_to_house
    return if house.blank? || sender.blank?
    return if house.users.exists?(id: sender_id)

    errors.add(:sender, 'must be a member of the house')
  end

  def assign_recipient_if_email_registered
    return if recipient_email.blank? || recipient.present?

    self.recipient = User.find_by(email: recipient_email)
  end

  def schedule_expiration
    MarkInviteAsExpiredJob.set(wait_until: expires_on + 1.minute).perform_later(self)
  end
end
