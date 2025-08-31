# frozen_string_literal: true

RSpec.shared_examples 'tag_filterable' do
  context 'when given a list of tags' do
    it 'can return items tagged with any of the given tags' do
      expect(described_class).to respond_to(:with_any_of_these_tags)
    end

    it 'can return items tagged with all of the given tags' do
      expect(described_class).to respond_to(:with_all_of_these_tags)
    end
  end
end
