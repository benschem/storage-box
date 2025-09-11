# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  subject(:room) do
    described_class.new(
      name: 'Garage',
      house: house
    )
  end

  let!(:house) { create(:house) }

  describe 'associations' do
    it { is_expected.to belong_to(:house).counter_cache(true) }
    it { is_expected.to have_many(:boxes).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:unboxed_items).class_name('Item').dependent(:restrict_with_error) }
    it { is_expected.to have_many(:boxed_items).through(:boxes).source(:items) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'scopes' do
    before do
      room.save!
    end

    describe ':in_house' do
      let!(:other_house) { create(:house) }
      let!(:other_room) { create(:room, house: other_house) }

      context 'when given a single house' do # rubocop:disable RSpec/NestedGroups
        subject(:rooms) { described_class.in_house(house) }

        it 'returns all of the rooms in that house' do
          aggregate_failures do
            expect(rooms).to be_a(ActiveRecord::Relation)
            expect(rooms).to contain_exactly(room)
          end
        end

        it 'does not return rooms from other houses' do
          expect(rooms).not_to include(other_room)
        end
      end

      context 'when given a list of houses' do # rubocop:disable RSpec/NestedGroups
        subject(:rooms) { described_class.in_house([house, other_house]) }

        it 'returns all of the rooms in all of those houses' do
          aggregate_failures do
            expect(rooms).to be_a(ActiveRecord::Relation)
            expect(rooms).to contain_exactly(room, other_room)
          end
        end

        it 'does not return rooms from other houses' do
          third_house = House.create!(name: 'house_3')
          third_room = described_class.new(name: 'room_3')
          third_room.house = third_house
          third_room.save!

          expect(rooms).not_to include(third_room)
        end
      end
    end
  end

  describe '#items' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let!(:house) { create(:house) }
    let!(:room) { create(:room, house: house) }
    let!(:box) { create(:box, room: room, house: house) }
    let!(:boxed_item) { create(:item, box: box, room: room, house: house) }
    let!(:unboxed_item) { create(:item, box: nil, room: room, house: house) }
    let!(:other_room) { create(:room, house: house) }
    let!(:item_in_other_room) { create(:item, room: other_room, house: house) }

    it 'returns all items in the room' do
      expect(room.items).to contain_exactly(boxed_item, unboxed_item)
    end

    it 'returns items in the room that are in a box' do
      expect(room.items).to include(boxed_item)
    end

    it 'returns items in the room that are not in a box' do
      expect(room.items).to include(unboxed_item)
    end

    it 'does not return items that are in another room' do
      expect(room.items).not_to include(item_in_other_room)
    end
  end
end
