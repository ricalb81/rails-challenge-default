require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe GenerateAccountKeyJob, type: :job do
  before do
    Sidekiq::Testing.fake!
  end

  let(:user) { create(:user) }
  let(:account_key) { SecureRandom.hex(32) }

  describe '#perform' do
    context 'when the external service returns success' do
      it 'updates the user with the account_key' do
        response_body = { account_key: account_key }.to_json
        stub_request(:post, AccessKeyService::URL_ACCOUNT_KEY).
          with(
            body: "{\"email\":\"#{user.email}\",\"key\":\"#{user.key}\"}",
            ).
          to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

        expect{
          GenerateAccountKeyJob.new.perform(user.id)
          user.reload
        }.to change(user, :account_key).from(nil).to(account_key)
      end
    end

    context 'when the user does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect(Rails.logger).to receive(:error).with("User with ID -1 not found")
        expect {
          GenerateAccountKeyJob.new.perform(-1)
        }.not_to raise_error
      end
    end
  end
end