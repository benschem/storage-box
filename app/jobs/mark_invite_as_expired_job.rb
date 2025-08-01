# frozen_string_literal: true

# Updates status on Invite to expired
class MarkInviteAsExpiredJob < ApplicationJob
  queue_as :default

  def perform(invite_id)
    invite = Invite.find_by(id: invite_id)

    return unless invite&.pending? && invite.expires_on <= Time.current

    invite.expired!
  end
end
