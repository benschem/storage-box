# frozen_string_literal: true

# Notifiable concern designed to extract Notification logic from Invite model.
module InviteNotifier
  extend ActiveSupport::Concern

  included do
    after_create_commit :notify_invitee_of_invite
  end

  def notify_of_acceptance_in_app(user:)
    broadcast_append_to "user_#{user.id}_invites",
                        partial: 'invites/invite_accepted',
                        target: 'notifications',
                        locals: { invite: self }
  end

  private

  def notify_invitee_of_invite
    if invitee
      notify_of_invite_in_app(user: invitee)
    else
      notify_of_invite_via_email(email: invitee_email)
    end
  end

  def notify_of_invite_in_app(user:)
    broadcast_append_to "user_#{user.id}_invites",
                        partial: 'invites/invite',
                        target: 'notifications',
                        locals: { invite: self }
  end

  def notify_of_invite_via_email(email:)
    # Send email asking to signup
    # InviteMailer.with(invite: self).invite_email.deliver_later
    # User gets notified upon account creation via callback in User model
  end
end
