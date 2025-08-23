# spec/policies/tag_policy_spec.rb
# frozen_string_literal: true

require 'rails_helper'
require 'pundit/matchers'

RSpec.describe TagPolicy do
  subject(:policy) { described_class.new(user, tag) }

  let(:tag) { create(:tag) }
  let(:user) { create(:user) }

  describe 'permissions for a new tag' do
    context 'when user is signed in' do
      it { is_expected.to permit_action(:create) }
    end

    context 'when user is not signed in' do
      let(:user) { nil }

      it { is_expected.to forbid_action(:create) }
    end
  end

  describe 'permissions for an existing tag' do
    context 'when user owns an item tagged with the tag' do
      let(:house) { create(:house) }

      before do
        house.users << user
        create(:tagging, tag: tag, item: create(:item, house: house))
      end

      it { is_expected.to permit_action(%i[remove]) }
      it { is_expected.to forbid_actions(%i[update destroy]) }
    end

    context 'when user does not own any items tagged with the tag' do
      it { is_expected.to forbid_actions(%i[remove update destroy]) }
    end

    context 'when other users also own an item tagged with the tag' do
      let(:house_with_user) { create(:house) }
      let(:house_without_user) { create(:house) }

      before do
        house_with_user.users << user

        create(:tagging, tag: tag, item: create(:item, house: house_with_user))
        create(:tagging, tag: tag, item: create(:item, house: house_without_user))
      end

      it { is_expected.to permit_actions(%i[remove]) }
      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end

  describe 'scope' do
    subject(:resolved) { described_class::Scope.new(user, Tag.all).resolve }

    context 'when tag is attached to item owned by user' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      before do
        item.tags << tag
        house.items << item
        house.users << user
      end

      it 'is returned' do
        expect(resolved).to include(tag)
      end
    end

    context 'when tag is attached to multiple items owned by user in the same house' do
      let(:house) { create(:house) }
      let(:items) { create_list(:item, 2, house: house) }

      before do
        items[0].tags << tag
        items[1].tags << tag
        house.users << user
      end

      it 'is returned only once' do
        expect(resolved.count).to eq(1)
      end
    end

    context 'when tag is attached to multiple items owned by user across different houses' do
      let(:houses) { create_list(:house, 2) }
      let(:item) { create(:item, house: houses[0]) }
      let(:second_item) { create(:item, house: houses[1]) }

      before do
        item.tags << tag
        second_item.tags << tag
        houses[0].users << user
        houses[1].users << user
      end

      it 'is returned only once' do
        expect(resolved.count).to eq(1)
      end
    end

    context 'when tag is attached to item not owned by user' do
      let(:second_user) { create(:user) }
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      before do
        house.users << second_user
        item.tags << tag
      end

      it 'is not returned' do
        expect(resolved).not_to include(tag)
      end
    end

    context 'when tag is attached to item owned by multiple users' do
      let(:houses) { create_list(:house, 2) }
      let(:item) { create(:item, house: houses[0]) }
      let(:second_item) { create(:item, house: houses[1]) }
      let(:second_user) { create(:user) }

      before do
        item.tags << tag
        houses[0].items << item
        houses[0].users << user

        second_item.tags << tag
        houses[1].items << second_item
        houses[1].users << second_user
      end

      it 'is returned' do
        expect(resolved).to include(tag)
      end
    end

    context 'when tag is not attached to any items' do
      let(:untagged_tag) { create(:tag) }

      it 'is not returned' do
        expect(resolved).not_to include(untagged_tag)
      end
    end
  end
end
