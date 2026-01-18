# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomPolicy, type: :policy do
  subject(:policy) { described_class.new(user, room) }

  describe 'permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:room) { build(:room) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is signed in' do
      let(:user) { create(:user, houses: [create(:house)]) }
      let(:room) { build(:room, house: user.houses.first) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when user is acting on a room in a house user is a member of' do
      let!(:house) { create(:house) }

      let(:user) { create(:user, houses: [house]) }
      let(:room) { create(:room, house:) }

      it { is_expected.to permit_actions(%i[show update destroy]) }
    end

    context 'when user is acting on a room in a house user is not a member of' do
      let!(:house) { create(:house) }

      let(:user) { create(:user, houses: []) }
      let(:room) { create(:room, house: house) }

      it { is_expected.to forbid_actions(%i[show update destroy]) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) do
      described_class::Scope.new(user, Room.all).resolve
    end

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no items' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user is a member of a house' do
      let!(:room) { create(:room, house: create(:house)) }
      let!(:room_in_other_house) { create(:room, house: create(:house)) }

      let(:user) { create(:user, houses: [room.house]) }

      it 'returns rooms in that house' do
        expect(resolved_scope).to include(room)
      end

      it 'does not return rooms in houses user is not a member of' do
        expect(resolved_scope).not_to include(room_in_other_house)
      end
    end
  end
end
