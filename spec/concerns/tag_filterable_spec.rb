# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TagFilterable', type: :concern do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let!(:item) { Item.all }
  let!(:tags) { create_list(:tag, 3) }
  let!(:item_with_first_tag) { create(:item, tags: [tags.first]) }
  let!(:item_with_first_and_second_tags) { create(:item, tags: [tags.first, tags.second]) }
  let!(:item_with_third_tag) { create(:item, tags: [tags.third]) }
  let!(:item_with_no_tags) { create(:item, tags: []) }

  describe '.with_any_of_these_tags' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:returned_relation) { item.with_any_of_these_tags(argument) }

    let(:argument) { [tags.first, tags.second] }

    it 'returns an ActiveRecord::Relation' do
      expect(returned_relation).to be_a(ActiveRecord::Relation)
    end

    it 'does not return duplicate items' do
      expect(returned_relation).to eq(returned_relation.uniq)
    end

    it 'does not return items with unrelated tags or no tags' do
      expect(returned_relation).not_to include(item_with_third_tag, item_with_no_tags)
    end

    context 'when given multiple tag objects' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first, tags.second] }

      it 'returns items tagged with any one of the given tags' do
        expect(returned_relation).to include(item_with_first_tag, item_with_first_and_second_tags)
      end
    end

    context 'when given multiple tag ids' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first.id, tags.second.id] }

      it 'returns items tagged with any one of the given tags' do
        expect(returned_relation).to include(item_with_first_tag, item_with_first_and_second_tags)
      end
    end

    context 'when given multiple tag names' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first.name, tags.second.name] }

      it 'returns items tagged with any one of the given tags' do
        expect(returned_relation).to include(item_with_first_tag, item_with_first_and_second_tags)
      end
    end

    context 'when given a mixture of tag objects, tag ids and tag names' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first, tags.second.id, tags.third.name] }

      it 'returns items tagged with any one of the tags' do
        expect(returned_relation).to include(item_with_first_tag, item_with_first_and_second_tags)
      end
    end

    context 'when given a single tag object' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { tags.first }

      it 'returns items tagged with the tag' do
        expect(returned_relation).to include(item_with_first_tag)
      end
    end

    context 'when given a single tag id integer' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { tags.first.id }

      it 'returns items tagged with the tag' do
        expect(returned_relation).to include(item_with_first_tag)
      end
    end

    context 'when given a single tag name string' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { tags.first.name }

      it 'returns items tagged with the tag' do
        expect(returned_relation).to include(item_with_first_tag)
      end
    end
  end

  describe '.with_all_of_these_tags' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    subject(:returned_relation) { item.with_all_of_these_tags(argument) }

    let(:argument) { [tags.first, tags.second] }

    it 'returns an ActiveRecord::Relation' do
      expect(returned_relation).to be_a(ActiveRecord::Relation)
    end

    it 'does not return duplicate items' do
      expect(returned_relation).to eq(returned_relation.uniq)
    end

    it 'does not return items with no tags' do
      expect(returned_relation).not_to include(item_with_no_tags)
    end

    context 'when given multiple tag objects' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first, tags.second] }

      it 'returns items tagged with all of the tags' do
        expect(returned_relation).to include(item_with_first_and_second_tags)
      end

      it 'does not return items tagged with only one of the tags' do
        expect(returned_relation).not_to include(item_with_first_tag)
      end
    end

    context 'when given multiple tag ids' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first.id, tags.second.id] }

      it 'returns items tagged with all of the tags' do
        expect(returned_relation).to include(item_with_first_and_second_tags)
      end

      it 'does not return items tagged with only one of the tags' do
        expect(returned_relation).not_to include(item_with_first_tag)
      end
    end

    context 'when given multiple tag names' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { [tags.first.name, tags.second.name] }

      it 'returns items tagged with all of the tags' do
        expect(returned_relation).to include(item_with_first_and_second_tags)
      end

      it 'does not return items tagged with only one of the tags' do
        expect(returned_relation).not_to include(item_with_first_tag)
      end
    end

    context 'when given a mixture of tag objects, tag ids and tag names' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:item_with_all_tags) { create(:item, tags: [tags.first, tags.second, tags.third]) }
      let(:argument) { [tags.first, tags.second.id, tags.third.name] }

      it 'returns items tagged with any one of the tags' do
        expect(returned_relation).to include(item_with_all_tags)
      end

      it 'does not return items tagged with only one of the tags' do
        expect(returned_relation).not_to include(item_with_first_tag,
                                                 item_with_first_and_second_tags,
                                                 item_with_third_tag)
      end
    end

    context 'when given a single tag object' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { tags.first }

      it 'returns items tagged with the tag' do
        expect(returned_relation).to include(item_with_first_tag)
      end
    end

    context 'when given a single tag id integer' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { tags.first.id }

      it 'returns items tagged with the tag' do
        expect(returned_relation).to include(item_with_first_tag)
      end
    end

    context 'when given a single tag name string' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:argument) { tags.first.name }

      it 'returns items tagged with the tag' do
        expect(returned_relation).to include(item_with_first_tag)
      end
    end
  end
end
