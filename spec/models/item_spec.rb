require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:item) { create(:item) }
  it 'must be in either a box or a room' do
    expect(item.box_id.present? || item.room_id.present?).to be true
  end
  it 'can be in a box only or a room only, but not both' do
    expect(item.box_id.present? && item.room_id.present?).to be false
  end
end
