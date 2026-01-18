# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagPolicy, type: :policy do
  subject(:policy) { described_class.new(user, tag) }

  describe 'Permissions' do
    context 'when user is not signed in' do
      let(:user) { nil }
      let(:tag) { build(:tag) }

      it { is_expected.to forbid_actions(%i[index show create update destroy]) }
    end

    context 'when user is signed in' do
      let(:user) { create(:user) }
      let(:tag) { build(:tag) }

      it { is_expected.to permit_action(:create) }
    end

    context 'when user is acting on a tag on an item in a house user is a member of' do
      let!(:house) { create(:house) }
      let(:item) { create(:item, house:) }

      let(:user) { create(:user, houses: [house]) }
      let(:tag) { create(:tag) }

      before do
        create(:tagging, tag:, item:)
      end

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end

    context 'when user is acting on a tag on an item in a house user is not a member of' do
      let(:item) { create(:item) }

      let(:user) { create(:user, houses: []) }
      let(:tag) { create(:tag) }

      before do
        create(:tagging, tag:, item:)
      end

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end

  describe 'Scope' do
    subject(:resolved_scope) { described_class::Scope.new(user, Tag.all).resolve }

    context 'when user is not signed in' do
      let(:user) { nil }

      it 'returns no tags' do
        expect(resolved_scope).to be_empty
      end
    end

    context 'when user is a member of a house' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }
      let(:tag) { create(:tag) }

      let(:user) { create(:user) }

      before do
        item.tags << tag
        house.items << item
        house.users << user
      end

      it 'returns tags on items in that house' do
        expect(resolved_scope).to include(tag)
      end
    end

    context 'when a tag is on multiple items in a house user is a member of' do
      let(:house) { create(:house) }
      let(:items) { create_list(:item, 2, house: house) }
      let(:tag) { create(:tag) }

      let(:user) { create(:user) }

      before do
        items[0].tags << tag
        items[1].tags << tag
        house.users << user
      end

      it 'returns tag only once' do
        expect(resolved_scope.count).to eq(1)
      end
    end

    context 'when a tag is on multiple items across multiple houses user is a member of' do
      let(:houses) { create_list(:house, 2) }
      let(:item) { create(:item, house: houses[0]) }
      let(:second_item) { create(:item, house: houses[1]) }
      let(:tag) { create(:tag) }

      let(:user) { create(:user) }

      before do
        item.tags << tag
        second_item.tags << tag
        houses[0].users << user
        houses[1].users << user
      end

      it 'returns tag only once' do
        expect(resolved_scope.count).to eq(1)
      end
    end

    context 'when a tag is on an item in a house user is not a member of' do
      let(:second_user) { create(:user) }
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }
      let(:tag) { create(:tag) }

      let(:user) { create(:user) }

      before do
        house.users << second_user
        item.tags << tag
      end

      it 'does not return tag' do
        expect(resolved_scope).not_to include(tag)
      end
    end

    context 'when a tag is not on any items' do
      let(:untagged_tag) { create(:tag) }

      let(:user) { create(:user) }

      it 'does not return tag' do
        expect(resolved_scope).not_to include(untagged_tag)
      end
    end
  end
end
