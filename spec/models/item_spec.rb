# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  subject(:item) do
    described_class.new(
      name: 'Screwdriver',
      notes: 'flathead',
      user: user,
      house: house,
      room: room,
      box: box
    )
  end

  let!(:user) { create(:user) }
  let!(:house) { create(:house) }
  let!(:room) { create(:room, house: house) }
  let!(:box) { create(:box, house: house) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:house) }
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:box).optional(true) }
    it { is_expected.to have_many(:tags).through(:taggings) }
    it { is_expected.to have_one_attached(:image) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:notes).is_at_most(255) }

    context "when in a box that's in a different house to the item" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let!(:different_house) { create(:house) }
      let!(:box_in_different_house) { create(:box, house: different_house) }
      let!(:item) { build(:item, box: box_in_different_house, house: house) }

      it 'is invalid' do
        expect(item).not_to be_valid
      end
    end

    context "when in a box that's in the same house as the item" do
      let!(:house) { create(:house) }
      let!(:box) { create(:box, house: house) }
      let!(:item) { build(:item, box: box, house: house) }

      it 'is valid' do
        expect(item).to be_valid
      end
    end

    context "when in a room that's in a different house to the item" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let!(:different_house) { create(:house) }
      let!(:room_in_different_house) { create(:room, house: different_house) }
      let!(:item) { build(:item, room: room_in_different_house, house: house) }

      it 'is invalid' do
        expect(item).not_to be_valid
      end
    end

    context "when in a room that's in the same house as the item" do
      let!(:house) { create(:house) }
      let!(:room) { create(:room, house: house) }
      let!(:item) { build(:item, room: room, house: house) }

      it 'is valid' do
        expect(item).to be_valid
      end
    end
  end

  it_behaves_like 'tag_filterable'

  describe '.search' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:item) do
      create(:item,
             name: 'Screwdriver',
             notes: 'flathead',
             user: user,
             house: house,
             room: room,
             box: box,
             tags: [tag])
    end

    let!(:other_items) { create_list(:item, 3) }
    let!(:tag) { create(:tag, name: 'tool') }

    it 'returns each item only once' do
      expect(described_class.search('s')).to eq(described_class.search('s').distinct)
    end

    it 'returns items where input matches item name exactly' do
      expect(described_class.search('Screwdriver')).to include(item)
    end

    it 'returns items where input matches item name case insensitively' do
      aggregate_failures do
        expect(described_class.search('screwdriver')).to include(item)
        expect(described_class.search('SCREWDRIVER')).to include(item)
        expect(described_class.search('ScReWdRiVeR')).to include(item)
      end
    end

    it 'returns items where input matches the first part of item name' do
      expect(described_class.search('Screw')).to include(item)
    end

    it 'does not return items where input does not match item name' do
      aggregate_failures do
        expect(described_class.search('Screwdriver')).not_to include(other_items)
        expect(described_class.search('Hammer')).not_to include(item)
      end
    end

    it 'returns items where input matches item notes exactly' do
      expect(described_class.search('flathead')).to include(item)
    end

    it 'returns items where input matches item notes case insensitively' do
      aggregate_failures do
        expect(described_class.search('Flathead')).to include(item)
        expect(described_class.search('FLATHEAD')).to include(item)
        expect(described_class.search('FlAtHeAd')).to include(item)
      end
    end

    it 'returns items where input matches the first part of item notes' do
      expect(described_class.search('flat')).to include(item)
    end

    it 'does not return items where input does not match item notes' do
      expect(described_class.search('phillips')).not_to include(item)
    end

    it 'returns tagged items where the tag name matches input exactly' do
      expect(described_class.search('tool')).to include(item)
    end

    it 'returns tagged items where the tag name matches input case insensitively' do
      aggregate_failures do
        expect(described_class.search('Tool')).to include(item)
        expect(described_class.search('TOOL')).to include(item)
        expect(described_class.search('ToOl')).to include(item)
      end
    end

    it 'returns no items if the input is blank' do # rubocop:disable RSpec/ExampleLength
      aggregate_failures do
        expect(described_class.search(nil)).to be_empty
        expect(described_class.search([])).to be_empty
        expect(described_class.search('')).to be_empty
        expect(described_class.search({})).to be_empty
      end
    end
  end

  context 'with an image' do
    before do
      item.image.attach(io: Rails.root.join('spec/fixtures/screwdriver.jpg').open, filename: 'image.jpg')
    end

    it 'purges image on save if asked' do
      item.remove_image = '1'
      item.save!

      expect(item.image).not_to be_attached
    end
  end
end
