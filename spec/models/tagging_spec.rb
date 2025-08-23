# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tagging, type: :model do
  subject { described_class.new(item:, tag:) }

  let(:item) { create(:item) }
  let(:tag) { create(:tag) }

  it { is_expected.to belong_to(:tag) }
  it { is_expected.to belong_to(:item) }
  it { is_expected.to validate_uniqueness_of(:tag_id).scoped_to(:item_id) }

  describe 'after_destroy callback' do
    context 'when the tag is still associated with other items' do
      before do
        create(:tagging, item: item, tag: tag)
        create(:tagging, item: create(:item), tag: tag)
      end

      it 'does not destroy the tag when one tagging is destroyed' do
        expect { tag.taggings.first.destroy }
          .not_to(change { Tag.exists?(tag.id) })
      end
    end

    context 'when the tag is only associated with one item' do
      before do
        create(:tagging, item: item, tag: tag)
      end

      it 'destroys the tag when the last tagging is destroyed' do
        expect { tag.taggings.first.destroy }
          .to change { Tag.exists?(tag.id) }.from(true).to(false)
      end
    end
  end
end
