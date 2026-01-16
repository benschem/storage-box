# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkInviteAsExpiredJob, type: :job do
  subject(:job) { described_class.new(invite.id) }

  let(:invite) { create(:invite, status:, expires_on:) }
  let(:status) { :pending }
  let(:expires_on) { 3.days.from_now }

  describe 'queue' do
    it 'is enqueued on the default queue' do
      pending 'how to test this'
    end
  end

  describe '#perform' do
    before { job.perform_now }

    context 'when invite status is pending' do
      context 'when date is after the invite expiry date' do
        let(:expires_on) { 1.day.ago }

        it 'marks the invite as expired' do
          expect(invite.reload).to be_expired
        end
      end

      context 'when date is before the invite expiry date' do
        it 'does not mark the invite as expired' do
          expect(invite.reload).not_to be_expired
        end
      end
    end

    %i[accepted declined expired].each do |status|
      context "when invite status is #{status}" do
        it 'does not mark the invite as expired' do
          expect(invite.reload).not_to be_expired
        end
      end
    end
  end
end
