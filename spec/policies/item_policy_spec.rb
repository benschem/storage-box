# spec/policies/tag_policy_spec.rb
# frozen_string_literal: true

require 'rails_helper'
require 'pundit/matchers'

RSpec.describe ItemPolicy do
  subject(:policy) { described_class.new(user, item) }

  let(:item) { create(:item) }
  let(:user) { create(:user) }

  describe 'a new item' do
    context 'when user is signed in' do
      it { is_expected.to permit_action(:create) }
    end

    context 'when user is not signed in' do
      let(:user) { nil }

      it { is_expected.to forbid_action(:create) }
    end
  end

  describe 'an existing item' do
    context 'when in house user belongs to' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      before do
        house.users << user
      end

      it { is_expected.to permit_actions(%i[update destroy]) }
    end

    context 'when in house user does not belong to' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end

  describe 'a collection of items' do
    subject(:resolved) { described_class::Scope.new(user, Item.all).resolve }

    context 'when user not signed in' do
      it 'returns no items' do
        expect(resolved).to be_empty
      end
    end

    context 'when an item is in a house that user belongs to' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      before do
        house.users << user
      end

      it 'is returned' do
        expect(resolved).to include(item)
      end
    end

    context 'when an item is in a house that user does not belong to' do
      let(:house) { create(:house) }
      let(:item) { create(:item, house: house) }

      it 'is not returned' do
        expect(resolved).not_to include(item)
      end
    end
  end
end
