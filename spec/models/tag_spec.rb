# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag do
  subject do
    described_class.new(
      name: 'tools',
      house: house
    )
  end

  let(:house) { create(:house) }

  describe 'associations' do
    it { is_expected.to belong_to(:house) }
    it { is_expected.to have_and_belong_to_many(:items) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:house_id) }
  end
end
