# frozen_string_literal: true

# Invites belong to a house, sender and recipient
class InvitePolicy < ApplicationPolicy
  def create?
    signed_in_user? && user_is_sender?
  end

  # Recipients can accept or decline a pending invite
  def update?
    signed_in_user? && user_is_recipient? && invite_pending?
  end

  # Users can see invites they have sent and recieved
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      sent = scope.where(sender: user)
      received = scope.where(recipient: user)

      # If recipient was not signed up to the app when the invite was sent,
      # recipient on invite will be nil, so it needs to also match user by email
      emailed = scope.where(recipient_email: user.email)

      sent.or(received).or(emailed)
    end
  end

  def user_is_sender?
    user == record.sender
  end

  def user_is_recipient?
    user == record.recipient || user.email == record.recipient_email
  end

  def invite_pending?
    record.pending?
  end
end
