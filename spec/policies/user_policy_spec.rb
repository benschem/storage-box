# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject(:policy) { described_class.new(current_user, user_record) }

  describe 'permissions' do
    context 'when no user is signed in' do
      let(:current_user) { nil }
      let(:user_record) { build(:user) }

      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_actions(%i[index show update destroy]) }
    end

    context 'when user is acting on themself' do
      let(:current_user) { build(:user) }
      let(:user_record) { current_user }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'when user is acting on another user' do
      let(:current_user) { build(:user) }
      let(:user_record) { build(:user) }

      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) do
      described_class::Scope.new(current_user, User.all).resolve
    end

    let!(:users) { create_list(:user, 3) }

    context 'when user is not signed in' do
      let(:current_user) { nil }

      it 'returns no users' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user is signed in' do
      let(:current_user) { users.first }

      it 'returns all users' do
        expect(resolved_scope).to match_array(users)
      end
    end
  end
end
