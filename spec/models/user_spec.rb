# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    described_class.new(
      name: 'Ben',
      email: 'ben@rocketzip.com.au',
      password: 'verySecurePassword123~'
    )
  end

  let(:user) { subject }

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:houses) }
    it { is_expected.to have_many(:rooms).through(:houses) }
    it { is_expected.to have_many(:boxes).through(:rooms) }
    it { is_expected.to have_many(:items).dependent(:restrict_with_error) }

    it do
      expect(user).to have_many(:sent_invites)
        .class_name('Invite')
        .with_foreign_key('inviter_id')
        .dependent(:destroy)
    end

    it do
      expect(user).to have_many(:received_invites)
        .class_name('Invite')
        .with_foreign_key('invitee_id')
        .dependent(:destroy)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'is expected to validate that user has a strong password' do
      user.password = 'weakpwd'
      expect(user).not_to be_valid
    end
  end

  describe '#accept_invite!' do
    let(:inviter) { create(:user) }
    let(:invitee) { create(:user) }

    context 'when user is the invitee and the invite is not already accepted, declined or expired' do
      let(:invite) do
        create(
          :invite,
          inviter: inviter,
          invitee: invitee,
          invitee_email: invitee.email,
          status: :pending,
          expires_on: 3.days.from_now
        )
      end

      before do
        invitee.accept_invite!(invite: invite)
      end

      it 'user joins the house on the invite' do
        expect(invite.house.users).to include(invitee)
      end

      it 'invite is marked as accepted' do
        expect(invite.status).to eq('accepted')
      end

      it 'inviter is notified'
    end

    context 'when user is not the invitee' do
      let(:invite) do
        create(
          :invite,
          inviter: inviter,
          invitee: invitee,
          invitee_email: invitee.email,
          status: :pending,
          expires_on: 3.days.from_now
        )
      end

      let(:some_other_user) { create(:user) }

      it 'raises an error' do
        expect do
          some_other_user.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'User was not invited')
      end

      it 'user does not join the house on the invite' do
        some_other_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(some_other_user)
      end

      it 'user does not cause invitee to join the house on invite' do
        some_other_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(invitee)
      end

      it 'user does not accept invite on behalf of invitee' do
        some_other_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('pending')
      end
    end

    context 'when already accepted' do
      let(:invite) do
        create(
          :invite,
          inviter: inviter,
          invitee: invitee,
          invitee_email: invitee.email,
          status: :accepted,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          invitee.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite has already been accepted')
      end

      it 'user does not join the house on the invite' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(invitee)
      end

      it 'invite status does not change' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('accepted')
      end
    end

    context 'when already declined' do
      let(:invite) do
        create(
          :invite,
          inviter: inviter,
          invitee: invitee,
          invitee_email: invitee.email,
          status: :declined,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          invitee.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite has already been declined')
      end

      it 'user does not join the house on the invite' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(invitee)
      end

      it 'invite status does not change' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('declined')
      end
    end

    context 'when expired' do
      let(:invite) do
        create(
          :invite,
          inviter: inviter,
          invitee: invitee,
          invitee_email: invitee.email,
          status: :expired,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          # binding.break
          invitee.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite is expired')
      end

      it 'user does not join the house on the invite' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(invitee)
      end

      it 'invite status does not change' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('expired')
      end
    end

    context 'when expires_on time has passed' do
      let(:invite) do
        build(
          :invite,
          inviter: inviter,
          invitee: invitee,
          invitee_email: invitee.email,
          status: :pending,
          expires_on: 3.days.ago
        )
      end

      it 'raises an error' do
        expect do
          invitee.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite is expired')
      end

      it 'user does not join the house on the invite' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(invitee)
      end

      it 'invite status does not change' do
        invitee.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('expired')
      end
    end
  end

  describe '#decline_invite!' do
    context 'when the user is invited and the invite is not already accepted, declined or expired' do
      let(:invite) do
        create(
          :invite,
          invitee: user,
          invitee_email: user.email,
          status: :pending,
          expires_on: 3.days.from_now
        )
      end

      before do
        user.decline_invite!(invite: invite)
      end

      it 'does not join the house on the invite' do
        expect(invite.house.users).not_to include(user)
      end

      it 'invite is marked as declined' do
        expect(invite.status).to eq('declined')
      end

      it 'inviter is not notified'
    end

    context 'when user was not invited' do
      let(:wrong_user) { create(:user) }
      let(:invite) do
        create(
          :invite,
          invitee: user,
          invitee_email: user.email,
          status: :pending,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          wrong_user.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'User was not invited')
      end

      it 'user does not join the house on the invite' do
        wrong_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(wrong_user)
      end

      it 'invite status does not change' do
        wrong_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('pending')
      end
    end

    context 'when the invite status is accepted' do
      let(:invite) do
        create(
          :invite,
          invitee: user,
          invitee_email: user.email,
          status: :accepted,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          user.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite has already been accepted')
      end

      it 'user does not join the house on the invite' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(user)
      end

      it 'invite status does not change' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('accepted')
      end
    end

    context 'when the invite status is declined' do
      let(:invite) do
        create(
          :invite,
          invitee: user,
          invitee_email: user.email,
          status: :declined,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          user.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite has already been declined')
      end

      it 'user does not join the house on the invite' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(user)
      end

      it 'invite status does not change' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('declined')
      end
    end

    context 'when the invite status is expired' do
      let(:invite) do
        create(
          :invite,
          invitee: user,
          invitee_email: user.email,
          status: :expired,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          user.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite is expired')
      end

      it 'user does not join the house on the invite' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(user)
      end

      it 'invite status does not change' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('expired')
      end
    end

    context 'when expires_on time has passed' do
      let(:invite) do
        build(
          :invite,
          invitee: user,
          invitee_email: user.email,
          status: :pending,
          expires_on: 3.days.ago
        )
      end

      it 'raises an error' do
        expect do
          user.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite is expired')
      end

      it 'user does not join the house on the invite' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(user)
      end

      it 'invite status does not change' do
        user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('expired')
      end
    end
  end
end
