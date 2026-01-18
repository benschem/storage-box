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
    it { is_expected.to have_many(:items).dependent(:restrict_with_error) }

    it do
      expect(user).to have_many(:sent_invites)
        .class_name('Invite')
        .with_foreign_key('sender_id')
        .dependent(:destroy)
    end

    it do
      expect(user).to have_many(:received_invites)
        .class_name('Invite')
        .with_foreign_key('recipient_id')
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
    let(:sender) { create(:user) }
    let(:recipient) { create(:user) }

    context 'when user is the recipient and the invite is pending' do
      let(:invite) do
        create(
          :invite,
          sender: sender,
          recipient: recipient,
          recipient_email: recipient.email,
          status: :pending,
          expires_on: 3.days.from_now
        )
      end

      before do
        recipient.accept_invite!(invite: invite)
      end

      it 'user joins the house on the invite' do
        expect(invite.house.users).to include(recipient)
      end

      it 'invite is marked as accepted' do
        expect(invite.status).to eq('accepted')
      end

      it 'sender is notified' do
        pending 'notifications being implemented'
      end
    end

    context 'when user is not the recipient' do
      let(:invite) do
        create(
          :invite,
          sender: sender,
          recipient: recipient,
          recipient_email: recipient.email,
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

      it 'user does not cause recipient to join the house on invite' do
        some_other_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(recipient)
      end

      it 'user does not accept invite on behalf of recipient' do
        some_other_user.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('pending')
      end
    end

    context 'when already accepted' do
      let(:invite) do
        create(
          :invite,
          sender: sender,
          recipient: recipient,
          recipient_email: recipient.email,
          status: :accepted,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          recipient.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite has already been accepted')
      end

      it 'user does not join the house on the invite' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(recipient)
      end

      it 'invite status does not change' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('accepted')
      end
    end

    context 'when already declined' do
      let(:invite) do
        create(
          :invite,
          sender: sender,
          recipient: recipient,
          recipient_email: recipient.email,
          status: :declined,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          recipient.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite has already been declined')
      end

      it 'user does not join the house on the invite' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(recipient)
      end

      it 'invite status does not change' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('declined')
      end
    end

    context 'when expired' do
      let(:invite) do
        create(
          :invite,
          sender: sender,
          recipient: recipient,
          recipient_email: recipient.email,
          status: :expired,
          expires_on: 3.days.from_now
        )
      end

      it 'raises an error' do
        expect do
          # binding.break
          recipient.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite is expired')
      end

      it 'user does not join the house on the invite' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(recipient)
      end

      it 'invite status does not change' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('expired')
      end
    end

    context 'when expires_on time has passed' do
      let(:invite) do
        build(
          :invite,
          sender: sender,
          recipient: recipient,
          recipient_email: recipient.email,
          status: :pending,
          expires_on: 3.days.ago
        )
      end

      it 'raises an error' do
        expect do
          recipient.accept_invite!(invite: invite)
        end.to raise_error(StandardError, 'Invite is expired')
      end

      it 'user does not join the house on the invite' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.house.users).not_to include(recipient)
      end

      it 'invite status does not change' do
        recipient.accept_invite!(invite: invite)
      rescue StandardError
        expect(invite.status).to eq('expired')
      end
    end
  end

  describe '#decline_invite!' do
    context 'when the user is invited and the invite is pending' do
      let(:invite) do
        create(
          :invite,
          recipient: user,
          recipient_email: user.email,
          status: :pending,
          expires_on: 3.days.from_now
        )
      end

      before do
        user.decline_invite!(invite: invite)
      end

      it 'user does not join the house on the invite' do
        expect(invite.house.users).not_to include(user)
      end

      it 'invite is marked as declined' do
        expect(invite.status).to eq('declined')
      end

      it 'sender is not notified' do
        pending 'notifications being implemented'
      end
    end

    context 'when user was not invited' do
      let(:wrong_user) { create(:user) }
      let(:invite) do
        create(
          :invite,
          recipient: user,
          recipient_email: user.email,
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
          recipient: user,
          recipient_email: user.email,
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
          recipient: user,
          recipient_email: user.email,
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
          recipient: user,
          recipient_email: user.email,
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
          recipient: user,
          recipient_email: user.email,
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

  describe '#transfer_items_to_user' do
    let!(:another_user) { create(:user) }
    let!(:items) { create_list(:item, 3, user:) }

    before do
      user.transfer_items_to_user(items: items, user: another_user)
    end

    context 'when user owns all the items' do
      it 'transfers all the items' do
        new_owners = items.map(&:reload).pluck(:user_id)
        expect(new_owners.uniq.count).to eq(1)
      end

      it 'items no longer belong to the original user' do
        new_owners = items.map(&:reload).pluck(:user_id)
        expect(new_owners).not_to include(user.id)
      end

      it 'items now belong to the new user' do
        new_owners = items.map(&:reload).pluck(:user_id)
        expect(new_owners.uniq).to eq([another_user.id])
      end
    end

    context 'when there are items that do not belong to user' do
      let!(:unrelated_user) { create(:user) }
      let!(:unowned_items) { create_list(:item, 3, user: unrelated_user) }

      before do
        user.transfer_items_to_user(
          items: items + unowned_items, user: another_user
        )
      end

      it 'transfers items that user does own' do
        new_owners = items.map(&:reload).pluck(:user_id)
        expect(new_owners.uniq).to eq([another_user.id])
      end

      it 'does not transfer items that belong to another user' do
        new_owners = unowned_items.map(&:reload).pluck(:user_id)
        expect(new_owners.uniq).to eq([unrelated_user.id])
      end
    end
  end
end
