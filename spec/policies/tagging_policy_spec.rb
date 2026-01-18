# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaggingPolicy, type: :policy do
  subject(:policy) { described_class.new(user, tagging) }

  let(:tag) { create(:tag) }

  describe 'Permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:tagging) { build(:tagging, tag:, item: create(:item)) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is acting on a tagging where item is in a house user is a member of' do
      let!(:house) { create(:house) }
      let(:item) { create(:item, house:) }

      let(:user) { create(:user, houses: [house]) }
      let(:tagging) { build(:tagging, tag:, item:) }

      it { is_expected.to permit_actions(%i[create destroy]) }
    end

    context 'when user is acting on a tagging where item is not in a house user is a member of' do
      let(:item) { create(:item) }

      let(:user) { create(:user, houses: []) }
      let(:tagging) { build(:tagging, tag:, item:) }

      it { is_expected.to forbid_actions(%i[create destroy]) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) { described_class::Scope.new(user, Tagging.all).resolve }

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no taggings' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user is a member of a particular house' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      let(:user) { create(:user, houses: [house]) }
      let!(:tagging) { create(:tagging, tag:, item:) }

      it 'returns taggings where the item is in that house' do
        expect(resolved_scope).to include(tagging)
      end
    end

    context 'when user is not a member of a particular house' do
      let(:item) { create(:item, house: create(:house)) }

      let(:user) { create(:user, houses: []) }
      let!(:tagging) { create(:tagging, tag:, item:) }

      it 'does not return taggings where the item is in that house' do
        expect(resolved_scope).not_to include(tagging)
      end
    end
  end
end
