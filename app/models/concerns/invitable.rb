# frozen_string_literal: true

# Invitable concern designed to extract Invite logic from User model.
module Invitable
  extend ActiveSupport::Concern

  class InviteError < StandardError; end

  included do
    has_many :sent_invites,
             class_name: 'Invite',
             foreign_key: 'sender_id',
             dependent: :destroy,
             inverse_of: :sender

    has_many :received_invites,
             class_name: 'Invite',
             foreign_key: 'recipient_id',
             dependent: :destroy,
             inverse_of: :recipient

    after_create_commit :check_for_invites
  end

  def accept_invite!(invite:)
    raise_if_errors(invite)

    transaction do
      invite.update!(status: :accepted)
      invite.house.users << self
      invite.notify_of_acceptance_in_app(user: invite.sender) # TODO: Do we need to do this? Views can use #status
    end
  end

  def decline_invite!(invite:)
    raise_if_errors(invite)

    invite.update!(status: :declined)
  end

  private

  def check_for_invites
    invites = Invite.where(recipient_email: email)
    return if invites.blank?

    invites.each do |invite|
      invite.update!(recipient: self)
    end
  end

  def invited?(invite)
    self == invite.recipient && email == invite.recipient_email
  end

  def member_of_house?(house)
    house.users.include?(self)
  end

  def raise_if_errors(invite)
    raise InviteError, 'User was not invited' unless invited?(invite)
    raise InviteError, 'User is already a member of the house' if member_of_house?(invite.house)
    raise InviteError, 'Invite is expired' if invite.overdue?
    raise InviteError, 'Invite is expired' if invite.expired?
    raise InviteError, 'Invite has already been accepted' if invite.accepted?
    raise InviteError, 'Invite has already been declined' if invite.declined?
  end
end
