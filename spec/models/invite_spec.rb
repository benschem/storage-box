# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invite, type: :model do
  subject do
    described_class.new(
      house: house,
      inviter: sender,
      invitee: nil,
      invitee_email: 'homer@simpson.com'
    )
  end

  let(:house) { create(:house) }
  let(:sender) { create(:user) }
  let(:invite) { subject }

  before do
    house.users << sender
  end

  describe 'associations' do
    it { is_expected.to belong_to(:house) }
    it { is_expected.to belong_to(:inviter).class_name('User') }
    it { is_expected.to belong_to(:invitee).class_name('User').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:invitee_email) }
    it { is_expected.to allow_value('test@example.com').for(:invitee_email) }
    it { is_expected.not_to allow_value('test').for(:invitee_email) }

    it 'is expected to validate that inviter belongs to house' do
      invite = build(:invite, :without_adding_inviter_to_house, inviter: sender, house: house)

      expect(invite).not_to be_valid
    end
  end

  it 'downcases and strips :invitee_email before validation' do
    invite = create(:invite, invitee_email: '  TEST@Example.COM  ')
    expect(invite.invitee_email).to eq('test@example.com')
  end

  it 'sets :expires_on timestamp to 3 days later before creation' do
    invite = create(:invite, expires_on: nil)
    expect(invite.expires_on).to be_within(1.minute).of(3.days.from_now)
  end

  it 'sets :token before creation' do
    invite = create(:invite, token: nil)
    expect(invite.token).to be_present
  end

  it 'has a unique :token' do
    existing_token = 'a' * 32
    create(:invite, token: existing_token)

    allow(SecureRandom).to receive(:urlsafe_base64).and_return(existing_token, 'b' * 32)

    invite = create(:invite)
    expect(invite.token).to eq('b' * 32)
  end

  it 'has a url safe :token' do
    invite = create(:invite)
    # URL-safe base64 includes only [-_A-Za-z0-9], no padding (=) or special chars.
    expect(invite.token).to match(/\A[\w\-]+\z/)
  end

  context 'when invitee_email matches a user' do
    let(:app_user) { create(:user) }
    let(:invite) { create(:invite, invitee: nil, invitee_email: app_user.email) }

    it 'assigns that user to invitee before creation' do
      expect(invite.invitee).to eq(app_user)
    end
  end

  context 'when invitee_email does not match a user' do
    let(:invite) { create(:invite, invitee: nil, invitee_email: 'not.a.user@example.com') }

    it 'does not assign any user to invitee before creation' do
      expect(invite.invitee).to be_nil
    end
  end

  describe 'notifies the invitee' do
    context 'when already a user of the app' do
      it 'notifies in-app' do
        pending 'notifications being implemented'
      end
    end

    context 'when not a user of the app' do
      it 'sent via email' do
        pending 'emails being setup'
      end
    end
  end
end
