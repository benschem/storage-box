# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invite, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:house) }
    it { is_expected.to belong_to(:inviter).class_name('User') }
    it { is_expected.to belong_to(:invitee).class_name('User').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:invitee_email) }
    it { is_expected.to allow_value('test@example.com').for(:invitee_email) }
  end

  describe 'callbacks' do
    it 'downcases and strips the invitee email before validation' do
      invite = create(:invite, invitee_email: '  TEST@Example.COM  ')
      expect(invite.invitee_email).to eq('test@example.com')
    end

    it 'generates a token before creation' do
      invite = create(:invite, token: nil)
      expect(invite.token).to be_present
    end

    it 'sets an expiry timestamp' do
      invite = create(:invite, expires_on: nil)
      expect(invite.expires_on).to be_within(1.minute).of(3.days.from_now)
    end
  end

  context 'when the invitee is already a user of the app' do
    it 'notifies the invitee via the app' do
    end
  end

  context 'when the invitee is not a user of the app' do
    it 'notifies the invitee via email' do
    end
  end

  describe 'when invitee accepts invite' do
  end

  describe 'when invitee declines invite' do
    # expect(invite.decline)
  end

  describe 'when invitee accepts invite' do
  end
end

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
