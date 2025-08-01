# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    described_class.new(
      name: 'Ben',
      email: 'ben@rocketzip.com.au',
      password: 'verySecurePassword123~'
    )
  end

  let(:user) { subject }

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:houses) }
    it { is_expected.to have_many(:rooms).through(:houses) }
    it { is_expected.to have_many(:boxes).through(:rooms) }
    it { is_expected.to have_many(:items).dependent(:restrict_with_error) }

    it do
      expect(user).to have_many(:sent_invites)
        .class_name('Invite')
        .with_foreign_key('inviter_id')
        .dependent(:destroy)
    end

    it do
      expect(user).to have_many(:received_invites)
        .class_name('Invite')
        .with_foreign_key('invitee_id')
        .dependent(:destroy)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'has a strong password' do
      user.password = 'weakpwd'
      expect(user).not_to be_valid
    end
  end
end
