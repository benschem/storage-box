# frozen_string_literal: true

require 'rails_helper'

module Queries
  RSpec.describe ItemFilter do
    let!(:house) { create(:house) }
    let!(:room)  { create(:room, house: house) }
    let!(:items) { create_list(:item, 3) }
    let(:items_relation) { Item.where(id: items.map(&:id)) }

    before do
      house.items << items.first
      house.items << items.second
      items.second.update!(room: room)
    end

    subject(:filtered_items) { described_class.apply(filters:, items: items_relation) }

    describe '#apply' do
      context 'with one valid filter' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:filters) { { house: house.id } }
        let(:expected) { items_relation.in_house(house.id) }

        it 'calls the scope mapped to that filter' do
          expect(filtered_items).to match_array(expected)
        end
      end

      context 'with multiple valid filters' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:filters) { { house: house.id, room: room.id } }
        let(:expected) { items_relation.in_house(house.id).in_room(room.id) }

        let(:applied_scopes) do
          applied = []
          described_class::FILTERS.each_value do |scope|
            allow(items_relation).to receive(scope) do
              applied << scope
              items_relation
            end
          end

          described_class.apply(filters: described_class::FILTERS, items: items_relation)
          applied
        end

        it 'calls all of the scopes mapped to those filters' do
          expect(filtered_items).to match_array(expected)
        end

        it 'applies each filter in the defined order' do
          expect(applied_scopes).to eq(described_class::FILTERS.values)
        end
      end

      context 'with both valid and invalid filters' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:filters) { { house: house.id, unknown: 'nonexistent' } }
        let(:expected) { items_relation.in_house(house.id) }

        it 'ignores unknown filters and applies valid ones' do
          expect(filtered_items).to match_array(expected)
        end
      end

      context 'with only invalid filters' do
        let(:filters) { { unknown: 'nonexistent' } }

        it 'returns the original scope unchanged' do
          expect(filtered_items).to match_array(items_relation)
        end
      end

      context 'with no filters' do
        let(:filters) { {} }

        it 'returns the original scope unchanged' do
          expect(filtered_items).to match_array(items_relation)
        end
      end

      describe 'sorting' do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let!(:item_a) { create(:item, name: 'A', created_at: 2.days.ago, updated_at: 1.day.ago) }
        let!(:item_b) { create(:item, name: 'B', created_at: 1.day.ago, updated_at: Time.current) }
        let(:items_relation) { Item.where(id: [item_a.id, item_b.id]) }

        context 'with valid sort params' do # rubocop:disable RSpec/MultipleMemoizedHelpers
          let(:filters) { { sort_by: 'name', sort_direction: 'asc' } }

          it 'sorts by the params' do
            expect(filtered_items).to eq([item_a, item_b])
          end
        end

        context 'with no sort params' do # rubocop:disable RSpec/MultipleMemoizedHelpers
          let(:filters) { {} }

          it 'falls back to sorting by :updated_at :desc' do
            expect(filtered_items).to eq([item_b, item_a])
          end
        end

        context 'with invalid sort params' do # rubocop:disable RSpec/MultipleMemoizedHelpers
          let(:filters) { { sort_by: 'unknown', sort_direction: 'sideways' } }

          it 'falls back to sorting by :updated_at :desc' do
            expect(filtered_items).to eq([item_b, item_a])
          end
        end
      end
    end
  end
end
