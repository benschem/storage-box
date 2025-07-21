require 'rails_helper'

RSpec.describe Box, type: :model do
  let(:house) { create(:house) }
  let(:room) { create(:room, house: house) }
  let(:box) { create(:box, room: room) }

  describe 'associations' do
    it { should belong_to(:room) }
    it { should have_many(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:number) }
  end

  it "set it's own number when created" do
    expect(box.number).to be_an(Integer)
  end

  it 'sets number to the next number within its house' do
    box
    second_box = create(:box, room: room)
    expect(second_box.number).to eq(box.number + 1)
  end

  it 'has a unique number within its house' do
    expect(box.house.boxes.where(number: box.number)).to contain_exactly(box)
  end
end
