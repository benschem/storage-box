# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BoxPolicy, type: :policy do
  subject(:policy) { described_class.new(user, box) }

  describe 'permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:box) { build(:box) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is acting on a box in a house user is a member of' do
      let(:user) { create(:user, houses: [create(:house)]) }
      let(:box) { create(:box, house: user.houses.first) }

      it { is_expected.to permit_actions(%i[show create update destroy]) }
    end

    context 'when user is acting on a box in a house user is not a member of' do
      let!(:house) { create(:house) }

      let(:user) { create(:user, houses: []) }
      let(:box) { create(:box, house: house) }

      it { is_expected.to forbid_actions(%i[show update destroy]) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) do
      described_class::Scope.new(user, Box.all).resolve
    end

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no boxes' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user is signed in and a member of a house' do
      let!(:box) { create(:box, house: create(:house)) }
      let!(:box_in_other_house) { create(:box, house: create(:house)) }

      let(:user) { create(:user, houses: [box.house]) }

      it 'returns boxes in that house' do
        expect(resolved_scope).to include(box)
      end

      it 'does not return boxes in houses user is not a member of' do
        expect(resolved_scope).not_to include(box_in_other_house)
      end
    end
  end
end
