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

  describe 'scopes' do
    describe ':in_houses' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:second_house) { build(:house) }
      let(:second_item) { build(:item, house: second_house) }

      before do
        item.save!
        second_house.save!
        second_item.save!
      end

      context 'when given a single house' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:items) { described_class.in_houses(house) }

        it 'returns all of the items in that house' do
          aggregate_failures do
            expect(items).to be_a(ActiveRecord::Relation)
            expect(items).to contain_exactly(item)
          end
        end

        it 'does not return items from other houses' do
          expect(items).not_to include(second_item)
        end
      end

      context 'when given a list of houses' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:items) { described_class.in_houses([house, second_house]) }

        let!(:third_house) { create(:house) }
        let!(:third_item) { create(:item, house: third_house) }

        it 'returns all of the items in all of those houses' do
          aggregate_failures do
            expect(items).to be_a(ActiveRecord::Relation)
            expect(items).to contain_exactly(item, second_item)
          end
        end

        it 'does not return items from other houses' do
          expect(items).not_to include(third_item)
        end
      end
    end

    describe ':in_rooms' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:second_room) { build(:room) }
      let(:second_item) { build(:box, room: second_room) }

      before do
        item.save!
        second_room.save!
        second_item.save!
      end

      context 'when given a single room' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:items) { described_class.in_rooms(room) }

        it 'returns all of the items in that room' do
          aggregate_failures do
            expect(items).to be_a(ActiveRecord::Relation)
            expect(items).to contain_exactly(item)
          end
        end

        it 'does not return items from other rooms' do
          expect(items).not_to include(second_item)
        end
      end

      context 'when given a list of rooms' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:items) { described_class.in_rooms([room, second_room]) }

        let!(:second_room) { create(:room, house: house) }
        let!(:second_item) { create(:item, room: second_room, house: house) }
        let!(:third_room) { create(:room, house: house) }
        let!(:third_item) { create(:item, room: third_room, house: house) }

        it 'returns all of the items in all of those rooms' do
          aggregate_failures do
            expect(items).to be_a(ActiveRecord::Relation)
            expect(items).to contain_exactly(item, second_item)
          end
        end

        it 'does not return items from other rooms' do
          expect(items).not_to include(third_item)
        end
      end
    end

    describe ':in_boxes' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:second_box) { build(:box, number: 2, house: house) }
      let(:second_item) { build(:item, box: second_box, house: house) }
      let!(:third_box) { build(:box, number: 3, house: house) }
      let!(:third_item) { build(:item, box: third_box, house: house) }

      before do
        item.save!
        second_box.save!
        second_item.save!
        third_box.save!
        third_item.save!
      end

      context 'when given a single box' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:items) { described_class.in_boxes(box) }

        it 'returns all of the items in that box' do
          aggregate_failures do
            expect(items).to be_a(ActiveRecord::Relation)
            expect(items).to contain_exactly(item)
          end
        end

        it 'does not return items from other boxes' do
          expect(items).not_to include(second_item)
        end
      end

      context 'when given a list of boxes' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        subject(:items) { described_class.in_boxes([box, second_box]) }

        it 'returns all of the items in all of those boxs' do
          aggregate_failures do
            expect(items).to be_a(ActiveRecord::Relation)
            expect(items).to contain_exactly(item, second_item)
          end
        end

        it 'does not return items from other boxes' do
          expect(items).not_to include(third_item)
        end
      end
    end

    describe ':boxed' do
      subject(:items) { described_class.boxed }

      let(:second_item) { build(:item, box: nil) }

      before do
        item.save!
        second_item.save!
      end

      it 'returns all of the items that are in a box' do
        aggregate_failures do
          expect(items).to be_a(ActiveRecord::Relation)
          expect(items).to contain_exactly(item)
        end
      end

      it 'does not return items that are not in a box' do
        expect(items).not_to include(second_item)
      end
    end

    describe ':unboxed' do
      subject(:items) { described_class.unboxed }

      let(:second_item) { build(:item, box: nil) }

      before do
        item.save!
        second_item.save!
      end

      it 'returns all of the items that are not in a box' do
        aggregate_failures do
          expect(items).to be_a(ActiveRecord::Relation)
          expect(items).to contain_exactly(second_item)
        end
      end

      it 'does not return items that are in a box' do
        expect(items).not_to include(item)
      end
    end

    describe ':with_any_of_these_tags' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      subject(:returned_relation) { described_class.with_any_of_these_tags(argument) }

      let!(:tags) { create_list(:tag, 3) }
      let!(:item_with_first_tag) { create(:item, tags: [tags.first]) }
      let!(:item_with_first_and_second_tags) { create(:item, tags: [tags.first, tags.second]) }
      let!(:item_with_third_tag) { create(:item, tags: [tags.third]) }
      let!(:item_with_no_tags) { create(:item, tags: []) }

      let(:argument) { [tags.first, tags.second] }

      context 'when given multiple tags' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        let(:argument) { [tags.first.id, tags.second.id] }

        it 'returns items tagged with any one of the given tags' do
          expect(returned_relation).to contain_exactly(item_with_first_tag, item_with_first_and_second_tags)
        end

        it 'returns an ActiveRecord::Relation' do
          expect(returned_relation).to be_a(ActiveRecord::Relation)
        end

        it 'does not return duplicate items' do
          expect(returned_relation).to eq(returned_relation.uniq)
        end

        it 'does not return items with no tags' do
          expect(returned_relation).not_to include(item_with_no_tags)
        end
      end

      context 'when given a single tag' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        let(:argument) { tags.third.id }

        it 'returns items tagged with the tag' do
          expect(returned_relation).to contain_exactly(item_with_third_tag)
        end

        it 'returns an ActiveRecord::Relation' do
          expect(returned_relation).to be_a(ActiveRecord::Relation)
        end

        it 'does not return duplicate items' do
          expect(returned_relation).to eq(returned_relation.uniq)
        end

        it 'does not return items with no tags' do
          expect(returned_relation).not_to include(item_with_no_tags)
        end
      end
    end

    describe ':with_all_of_these_tags' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      subject(:returned_relation) { described_class.with_all_of_these_tags(argument) }

      let!(:tags) { create_list(:tag, 3) }
      let!(:item_with_first_tag) { create(:item, tags: [tags.first]) }
      let!(:item_with_first_and_second_tags) { create(:item, tags: [tags.first, tags.second]) }
      let!(:item_with_third_tag) { create(:item, tags: [tags.third]) }
      let!(:item_with_no_tags) { create(:item, tags: []) }

      let(:argument) { [tags.first.id, tags.second.id] }

      context 'when given multiple tags' do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
        let(:argument) { [tags.first.id, tags.second.id] }

        it 'returns items tagged with all of the tags' do
          expect(returned_relation).to contain_exactly(item_with_first_and_second_tags)
        end

        it 'does not return items tagged with only one of the tags' do
          expect(returned_relation).not_to include(item_with_first_tag)
        end

        it 'returns an ActiveRecord::Relation' do
          expect(returned_relation).to be_a(ActiveRecord::Relation)
        end

        it 'does not return duplicate items' do
          expect(returned_relation).to eq(returned_relation.uniq)
        end

        it 'does not return items with no tags' do
          expect(returned_relation).not_to include(item_with_no_tags)
        end
      end

      context 'when given a single tag' do
        let(:argument) { tags.third.id }

        it 'returns items tagged with the tag' do
          expect(returned_relation).to contain_exactly(item_with_third_tag)
        end

        it 'returns an ActiveRecord::Relation' do
          expect(returned_relation).to be_a(ActiveRecord::Relation)
        end

        it 'does not return duplicate items' do
          expect(returned_relation).to eq(returned_relation.uniq)
        end

        it 'does not return items with no tags' do
          expect(returned_relation).not_to include(item_with_no_tags)
        end
      end
    end
  end

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
