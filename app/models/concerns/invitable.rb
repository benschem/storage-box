# frozen_string_literal: true

# Invitable concern designed to extract Invite logic from User model.
module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :sent_invites,
             class_name: 'Invite',
             foreign_key: 'inviter_id',
             dependent: :destroy,
             inverse_of: :inviter

    has_many :received_invites,
             class_name: 'Invite',
             foreign_key: 'invitee_id',
             dependent: :destroy,
             inverse_of: :invitee

    after_create_commit :check_for_invites
  end

  def accept_invite(invite:)
    # TODO: Think about using custom errors here
    raise StandardError, 'User was not invited' unless invited?(invite)
    raise StandardError, 'User is already a member of the house' if member_of_house?(invite.house)
    raise StandardError, 'Invite is expired' if invite.expired?

    transaction do
      invite.update!(status: :accepted)
      invite.house.users << self
      invite.notify_of_acceptance_in_app(user: invite.inviter) # TODO: Do we need to do this? Views can use #status
    end
  end

  def decline_invite(invite:)
    invite.update!(status: :declined)
  end

  private

  def check_for_invites
    invites = Invite.where(invitee_email: email)
    return if invites.blank?

    invites.each do |invite|
      invite.update!(invitee: self)
    end
  end

  def invited?(invite)
    self == invite.invitee && email == invite.invitee_email
  end

  def member_of_house?(house)
    house.users.includes(invitee)
  end
end
