require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:house) { create(:house) }

  subject {
    described_class.new(
      name: 'tools',
      house: house
    )
  }

  it { should belong_to(:house) }
  it { should have_and_belong_to_many(:items) }
  it { should validate_uniqueness_of(:name).scoped_to(:house_id) }
end
