require 'rails_helper'

RSpec.describe House, type: :model do
  describe 'associations' do
    it { should have_and_belong_to_many(:users) }
    it { should have_many(:rooms).dependent(:restrict_with_error) }
    it { should have_many(:boxes).through(:rooms) }
    it { should have_many(:items) }
    it { should have_many(:invites).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
