require 'rails_helper'

RSpec.describe Box, type: :model do
  let(:house) { create(:house) }
  let(:room) { create(:room, house: house) }

  subject {
    described_class.new(
      number: 1,
      room: room,
      house: house
    )
  }

  describe 'associations' do
    it { should belong_to(:house) }
    it { should belong_to(:room) }
    it { should have_many(:items) }
  end

  let!(:box_1) { create(:box, room: room, house: house) }
  let!(:box_2) { create(:box, room: room, house: house) }
  let!(:box_3) { create(:box, room: room, house: house) }

  it 'increments room.boxes_count when created' do
    expect {
      create(:box, room: room, house: house)
    }.to change { room.reload.boxes_count }.by(1)
  end

  it 'decrements room.boxes_count when deleted' do
    expect {
      box_1.destroy!
    }.to change { room.reload.boxes_count }.by(-1)
  end

  it 'is numbered sequentially within a house' do
    box_numbers = house.boxes.pluck(:number)
    expect(box_numbers).to match_array([1, 2, 3])
  end

  it 'has a unique number within a house' do
    box_numbers = house.boxes.pluck(:number)
    expect(box_numbers).to match_array([1, 2, 3])
  end

  it 'cannot have a duplicate number within a house' do
    duplicate = build(:box, number: 1, room: room, house: house)
    expect(duplicate).not_to be_valid
  end

  context 'when the highest numbered box was previously deleted' do
    let!(:deleted_box_number) { box_3.number }

    before do
      box_3.destroy!
    end

    let!(:new_box) { create(:box, room: room, house: house) }

    it "is assigned the next highest number in the house (reuses deleted number)" do
      expect(new_box.number).to eq(deleted_box_number)
    end

    it 'still has a unique number per house' do
      box_numbers = house.boxes.pluck(:number)
      expect(box_numbers).to match_array([1, 2, 3])
    end
  end

  context 'when a lower numbered box was previously deleted' do
    let!(:deleted_box_number) { box_2.number }

    before do
      box_2.destroy!
    end

    let!(:new_box) { create(:box, room: room, house: house) }

    it 'is assigned the next highest number in the house (does not reuse deleted number)' do
      expect(new_box.number).to eq(4)
    end

    it 'still has a unique number per house' do
      box_numbers = house.boxes.pluck(:number)
      expect(box_numbers).to match_array([1, 3, 4])
    end
  end

  context 'when there are multiple houses' do
    let!(:house_2) { create(:house) }
    let!(:room_in_house_2) { create(:room, house: house_2) }
    let!(:box_4) { create(:box, room: room_in_house_2, house: house_2) }
    let!(:box_5) { create(:box, room: room_in_house_2, house: house_2) }
    let!(:box_6) { create(:box, room: room_in_house_2, house: house_2) }

    it 'is numbered starting from 1 in each house independently' do
      expect(box_4.number).to eq(1)
    end

    it 'can have the same number as a box within a different house' do
      expect(box_4).to be_valid
    end

    it 'still has a unique number per house' do
      box_numbers = house_2.boxes.pluck(:number)
      expect(box_numbers).to match_array([1, 2, 3])
    end
  end
end
