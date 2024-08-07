# spec/jobs/generate_keys_job_spec.rb
require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake! # Use Sidekiq's fake testing mode

RSpec.describe GenerateKeysJob, type: :job do
  before do
    allow_any_instance_of(AccessKeyService).to receive(:generate_account_key).and_return(SecureRandom.hex(32))
  end

  describe '#perform' do
    let!(:user_with_account_key) { create(:user) }
    let!(:user_without_account_key_1) { create(:user) }
    let!(:user_without_account_key_2) { create(:user) }

    before do
      Sidekiq::Worker.clear_all
    end

    before(:each) do
      user_without_account_key_1.reload.update(account_key: nil)
      user_without_account_key_2.reload.update(account_key: nil)
    end

    it 'enqueues GenerateAccountKeyJob for users without an account key' do
      expect {
        GenerateKeysJob.new.perform
      }.to change(GenerateAccountKeyJob.jobs, :size).by(2)

      enqueued_jobs = GenerateAccountKeyJob.jobs.map { |job| job['args'].first }
      expect(enqueued_jobs).to include(user_without_account_key_1.id, user_without_account_key_2.id)
      expect(enqueued_jobs).not_to include(user_with_account_key.id)
    end

    it 'does not enqueue GenerateAccountKeyJob for users with an existing account key' do
      GenerateKeysJob.new.perform
      enqueued_jobs = GenerateAccountKeyJob.jobs.map { |job| job['args'].first }
      expect(enqueued_jobs).not_to include(user_with_account_key.id)
    end
  end
end
