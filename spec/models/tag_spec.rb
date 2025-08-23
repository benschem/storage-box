# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  subject do
    described_class.new(
      name: 'tools'
    )
  end

  describe 'associations' do
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:items).through(:taggings) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
