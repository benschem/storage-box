require 'rails_helper'

RSpec.describe Box, type: :model do
  subject(:first_box) do
    described_class.new(
      number: 1,
      room: room,
      house: house
    )
  end

  let!(:house) { create(:house) }
  let!(:room) { create(:room, house: house) }
  let(:second_box) { build(:box, room: room, house: house) }
  let(:third_box) { build(:box, room: room, house: house) }

  before do
    first_box.save!
    second_box.save!
    third_box.save!
  end

  describe 'associations' do
    it { is_expected.to belong_to(:house) }
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:items) }
  end

  describe 'scopes' do
    describe ':in_house' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:second_house) { build(:house) }
      let(:fourth_box) { build(:box, house: second_house) }

      before do
        second_house.save!
        fourth_box.save!
      end

      context 'when given a single house' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:boxes) { described_class.in_house(house) }

        it 'returns all of the boxes in that house' do
          aggregate_failures do
            expect(boxes).to be_a(ActiveRecord::Relation)
            expect(boxes).to contain_exactly(first_box, second_box, third_box)
          end
        end

        it 'does not return boxes from other houses' do
          expect(boxes).not_to include(fourth_box)
        end
      end

      context 'when given a list of houses' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:boxes) { described_class.in_house([house, second_house]) }

        it 'returns all of the boxes in all of those houses' do
          aggregate_failures do
            expect(boxes).to be_a(ActiveRecord::Relation)
            expect(boxes).to contain_exactly(first_box, second_box, third_box, fourth_box)
          end
        end

        it 'does not return boxes from other houses' do
          third_house = House.create!(name: 'house_3')
          third_box.house = third_house
          third_box.save!

          expect(boxes).not_to include(third_box)
        end
      end
    end

    describe ':in_room' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:second_room) { build(:room) }
      let(:fourth_box) { build(:box, room: second_room) }

      before do
        second_room.save!
        fourth_box.save!
      end

      context 'when given a single room' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:boxes) { described_class.in_room(room) }

        it 'returns all of the boxes in that room' do
          aggregate_failures do
            expect(boxes).to be_a(ActiveRecord::Relation)
            expect(boxes).to contain_exactly(first_box, second_box, third_box)
          end
        end

        it 'does not return boxes from other rooms' do
          expect(boxes).not_to include(fourth_box)
        end
      end

      context 'when given a list of rooms' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:boxes) { described_class.in_room([room, second_room]) }

        it 'returns all of the boxes in all of those rooms' do
          aggregate_failures do
            expect(boxes).to be_a(ActiveRecord::Relation)
            expect(boxes).to contain_exactly(first_box, second_box, third_box, fourth_box)
          end
        end

        it 'does not return boxes from other rooms' do
          third_room = Room.create!(name: 'room_3', house: house)
          third_box.room = third_room
          third_box.save!

          expect(boxes).not_to include(third_box)
        end
      end
    end
  end

  it 'increments room.boxes_count when created' do
    expect do
      create(:box, room: room, house: house)
    end.to change { room.reload.boxes_count }.by(1)
  end

  it 'decrements room.boxes_count when deleted' do
    expect do
      first_box.destroy!
    end.to change { room.reload.boxes_count }.by(-1)
  end

  describe 'sets own number on creation' do
    it 'is numbered sequentially within a house' do
      box_numbers = house.boxes.pluck(:number)
      expect(box_numbers).to contain_exactly(1, 2, 3)
    end

    it 'cannot have a duplicate number within a house' do
      duplicate = build(:box, number: 1, room: room, house: house)
      expect(duplicate).not_to be_valid
    end

    context 'when a numbered box was previously deleted' do
      let!(:deleted_box_number) { second_box.number }
      let!(:new_box) { create(:box, room: room, house: house) }

      before do
        second_box.destroy!
      end

      it 'uses the next highest number in the house (does not reuse deleted number)' do
        expect(new_box.number).to eq(4)
      end

      it 'number is still unique per house' do
        box_numbers = house.boxes.pluck(:number)
        expect(box_numbers).to contain_exactly(1, 3, 4)
      end
    end

    context 'when there are multiple houses' do
      let!(:second_house) { create(:house) }
      let!(:room_in_second_house) { create(:room, house: second_house) }
      let!(:boxes_in_second_house) { create_list(:box, 3, room: room_in_second_house, house: second_house) }

      it 'is numbered starting from 1 in each house independently' do
        expect(boxes_in_second_house.first.number).to eq(1)
      end

      it 'can have the same number as a box within a different house' do
        aggregate_failures do
          expect(boxes_in_second_house.first.number).to eq(first_box.number)
          expect(boxes_in_second_house.first).to be_valid
        end
      end

      it 'still has a unique number per house' do
        box_numbers = second_house.boxes.pluck(:number)
        expect(box_numbers).to contain_exactly(1, 2, 3)
      end
    end
  end
end
