require 'rails_helper'

RSpec.describe Room, type: :model do
  let(:house) { build(:house) }

  subject {
    described_class.new(
      name: 'Garage',
      house: house
    )
  }

  describe 'associations' do
    it { should belong_to(:house).counter_cache(true) }
    it { should have_many(:boxes).dependent(:destroy) }
    it { should have_many(:unboxed_items).class_name('Item') }
    it { should have_many(:boxed_items).through(:boxes).source(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#items' do
    let!(:house) { create(:house) }
    let!(:room) { create(:room, house: house) }
    let!(:box) { create(:box, room: room, house: house) }
    let!(:boxed_item) { create(:item, box: box, room: room, house: house) }
    let!(:unboxed_item) { create(:item, box: nil, room: room, house: house) }

    it 'returns all items in the room' do
      expect(room.items).to contain_exactly(boxed_item, unboxed_item)
    end

    it 'returns items in the room that are in a box' do
      expect(room.items).to include(boxed_item)
    end

    it 'returns items in the room that are not in a box' do
      expect(room.items).to include(unboxed_item)
    end

    let!(:other_room) { create(:room, house: house) }
    let!(:item_in_other_room) { create(:item, room: other_room, house: house) }

    it 'does not return items that are in another room' do
      expect(room.items).to_not include(item_in_other_room)
    end
  end
end
