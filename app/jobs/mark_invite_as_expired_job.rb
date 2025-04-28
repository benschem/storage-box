class MarkInviteAsExpiredJob < ApplicationJob
  queue_as :default

  def perform(invite_id)
    invite = Invite.find_by(id: invite_id)

    if invite && invite.expires_on <= Time.current && invite.pending?
      invite.expired!
    end
  end
end
