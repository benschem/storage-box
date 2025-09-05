# frozen_string_literal: true

require 'rails_helper'

module Queries
  RSpec.describe Filter do
    subject(:filtered_items) { described_class.apply(filters:, to: items_relation) }

    let(:filters) { {} }

    let!(:house) { create(:house) }
    let!(:room) { create(:room, house: house) }
    let!(:items) { create_list(:item, 3) }
    let(:items_relation) { Item.where(id: items.map(&:id)) }

    before do
      house.items << items.first
      house.items << items.second
      items.second.update!(room: room)
    end

    it 'returns an ActiveRecord::Relation' do
      expect(filtered_items).to be_a(ActiveRecord::Relation)
    end

    context 'when given one valid filter' do
      let(:filters) { { filter_by_house: house.id } }

      it 'calls the scope mapped to that filter' do
        expected = items_relation.in_house(house.id)
        expect(filtered_items).to match_array(expected)
      end

      context 'when given multiple valid filters' do
        let(:filters) { { filter_by_house: house.id, filter_by_room: room.id } }

        it 'calls all of the scopes mapped to those filters' do
          expected = items_relation.in_house(house.id).in_room(room.id)
          expect(filtered_items).to match_array(expected)
        end
      end

      context 'when given both valid and invalid filters' do
        let(:filters) { { filter_by_house: house.id, unknown: 'nonexistant' } }

        it 'ignores unknown filters and applies valid ones' do
          expected = items_relation.in_house(house.id)
          expect(filtered_items).to match_array(expected)
        end
      end

      context 'when given an invalid filter' do
        let(:filters) { { unknown: 'nonexistant' } }

        it 'returns the original scope unchanged' do
          expect(filtered_items).to match_array(items_relation)
        end
      end

      context 'when given empty filters' do
        let(:filters) { {} }

        it 'returns the original scope' do
          expect(filtered_items).to match_array(items_relation)
        end
      end
    end
  end
end
