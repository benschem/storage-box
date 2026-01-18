# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HousePolicy, type: :policy do
  subject(:policy) { described_class.new(user, house) }

  describe 'permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:house) { build(:house) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }
      let(:house) { build(:house) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when user is acting on a house user is a member of' do
      let!(:house) { create(:house) }
      let(:user) { create(:user, houses: [house]) }

      it { is_expected.to permit_actions(%i[update destroy]) }
    end

    context 'when user is acting on a house user is not a member of' do
      let(:house) { create(:house) }
      let(:user) { create(:user, houses: []) }

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) do
      described_class::Scope.new(user, House.all).resolve
    end

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no houses' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user is signed in' do
      let!(:house) { create(:house) }
      let!(:other_house) { create(:house) }
      let(:user) { create(:user, houses: [house]) }

      it 'returns houses they are a member of' do
        expect(resolved_scope).to include(house)
      end

      it 'does not return houses they are not a member of' do
        expect(resolved_scope).not_to include(other_house)
      end
    end
  end
end
