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

    # TODO: Think about a trait for the house factory - different_house?
    context "when in a box that's in a different house to the item" do
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

    # TODO: Think about a trait for the house factory - different_house?
    context "when in a room that's in a different house to the item" do
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

  describe 'class methods' do
    describe '.with_any_of_these_tags' do
      subject(:scope) { described_class.with_any_of_these_tags([tags.first, tags.second]) }

      let(:items) { create_list(:item, 2) }
      let(:tags) { create_list(:tag, 2) }

      before do
        items.first.tags << tags.first
        items.first.tags << tags.second
        items.second.tags << tags.second
      end

      it 'returns items tagged with any one of the given tags' do
        expect(scope).to include(items.first, items.second)
      end

      it 'returns items tagged with all of the given tags' do
        expect(scope).to include(items.first)
      end

      it 'does not return items tagged with tags that do not match any of the given tags' do
        # expect(scope).not_to include(items.fourth)
        pending 'a better factory setup or a fourth item here'
      end

      it 'does not return items without any tags' do
        expect(scope).not_to include(items.third)
      end
    end

    describe '.with_all_of_these_tags' do
      subject(:scope) { described_class.with_all_of_these_tags([tags.first, tags.second]) }

      let(:items) { create_list(:item, 2) }
      let(:tags) { create_list(:tag, 2) }

      before do
        items.first.tags << tags.first
        items.first.tags << tags.second
        items.second.tags << tags.second
      end

      it 'returns items tagged with all of the given tags' do
        expect(scope).to include(items.first)
      end

      it 'does not return items tagged with only one of the given tags' do
        expect(scope).not_to include(items.second)
      end

      it 'does not return items tagged with tags that do not match any of the given tags' do
        # expect(scope).not_to include(item.fourth)
        pending 'a better factory setup or a fourth item here'
      end

      it 'does not return items without any tags' do
        expect(scope).not_to include(items.third)
      end
    end

    describe '.search' do
      let!(:tag) { create(:tag, name: 'tool') }

      before do
        item.save!
        item.tags << tag
      end

      it 'returns items matching name' do
        expect(described_class.search('screw')).to include(item)
      end

      it 'returns items matching notes' do
        expect(described_class.search('flat')).to include(item)
      end

      it 'returns items matching tag name' do
        expect(described_class.search('tool')).to include(item)
      end

      it 'returns nothing for blank input' do
        expect(described_class.search(nil)).to be_empty
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
