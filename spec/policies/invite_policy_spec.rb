# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvitePolicy, type: :policy do
  subject(:policy) { described_class.new(user, invite) }

  describe 'permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:invite) { create(:invite) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is sender' do
      let(:house) { create(:house) }

      let(:user) { create(:user, houses: [house]) }
      let(:invite) { create(:invite, sender: user, house: house) }

      # Sender can create invite
      it { is_expected.to permit_action(:create) }

      # Sender can not accept or decline invite
      it { is_expected.to forbid_action(:update) }
    end

    context 'when user is recipient' do
      context 'when invite received via the app and invite is pending' do
        let(:user) { create(:user) }
        let(:invite) { create(:invite, recipient: user) }

        before { invite.update!(status: 'pending') }

        # Recipient can accept or decline pending invite
        it { is_expected.to permit_action(:update) }
      end

      context 'when invite received via email and invite is pending' do
        let(:user) { create(:user) }
        let(:invite) { create(:invite, :email_only, recipient_email: user.email) }

        before { invite.update(status: 'pending') }

        # Recipient can accept or decline pending invite
        it { is_expected.to permit_action(:update) }
      end

      Invite.statuses.except('pending').each_key do |status|
        context "when invite status is #{status}" do
          let(:user) { create(:user) }
          let(:invite) { create(:invite, recipient: user) }

          before { invite.update!(status:) }

          # Recipient can not accept or decline non-pending invites
          it { is_expected.to forbid_action(:update) }
        end
      end

      context 'when user is neither sender nor recipient' do
        let(:user) { create(:user) }
        let(:invite) { create(:invite) }

        # Users not on the invite cannot create, accept or decline invite
        it { is_expected.to forbid_actions(:create, :update) }
      end
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) do
      described_class::Scope.new(user, Invite.all).resolve
    end

    let(:user) { create(:user) }

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no invites' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user has sent invites' do
      let(:sent_invites) { create_list(:invite, 2, sender: user) }

      it 'returns their sent invites' do
        expect(resolved_scope).to match_array(sent_invites)
      end
    end

    context 'when user has received invite via the app' do
      let(:received_invite) { create(:invite, recipient: user) }

      it 'returns their receieved invites' do
        expect(resolved_scope).to contain_exactly(received_invite)
      end
    end

    context 'when user has received invite via email' do
      let(:received_invite) { create(:invite, :email_only, recipient_email: user.email) }

      it 'returns their receieved invites' do
        expect(resolved_scope).to contain_exactly(received_invite)
      end
    end

    context 'when user has received invites via both the app and email' do
      let(:received_via_app) { create(:invite, recipient: user) }
      let(:received_via_email) { create(:invite, :email_only, recipient_email: user.email) }

      it 'returns their receieved invites' do
        expect(resolved_scope).to contain_exactly(received_via_app, received_via_email)
      end
    end
  end
end
