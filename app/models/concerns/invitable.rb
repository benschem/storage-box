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

  def accept_invite(invite)
    raise StandardError, 'User was not invited' unless invited?(invite)
    raise StandardError, 'User is already a member of the house' if member_of_house?(invite.house)

    transaction do
      invite.update!(status: :accepted)
      invite.house.users << self
      # notify_inviter_of_acceptance
    end
  end

  def decline(invite)
    invite.update!(status: :declined)
  end

  private

  def check_for_invites
    invites = Invite.where(invitee_email: email)
    return if invites.blank?

    invites.each do |invite|
      invite.update!(invitee: self)
      # NotifyUserOfNewHouseInvite.perform_later(invite)
    end
  end

  def invited?(invite)
    self == invite.invitee && email == invite.invitee_email
  end

  def member_of_house?(house)
    house.users.includes(invitee)
  end
end
