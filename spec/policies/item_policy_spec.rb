# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ItemPolicy, type: :policy do
  subject(:policy) { described_class.new(user, item) }

  describe 'permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:item) { build(:item) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }
      let(:item) { build(:item) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when user is acting on an item in a house user is a member of' do
      let!(:house) { create(:house) }

      let(:user) { create(:user, houses: [house]) }
      let(:item) { create(:item, house:) }

      it { is_expected.to permit_actions(%i[show update destroy]) }
    end

    context 'when user is acting on an item in a house user is not a member of' do
      let!(:house) { create(:house) }

      let(:user) { create(:user, houses: []) }
      let(:item) { create(:item, house: house) }

      it { is_expected.to forbid_actions(%i[show update destroy]) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) do
      described_class::Scope.new(user, Item.all).resolve
    end

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no items' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user belongs a house' do
      let!(:item) { create(:item, house: create(:house)) }
      let!(:item_in_other_house) { create(:item, house: create(:house)) }

      let(:user) { create(:user, houses: [item.house]) }

      it 'returns items in that house' do
        expect(resolved_scope).to include(item)
      end

      it 'does not return items in houses user does not belong to' do
        expect(resolved_scope).not_to include(item_in_other_house)
      end
    end
  end
end
