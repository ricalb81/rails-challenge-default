require 'rails_helper'

RSpec.describe AccessKeyService do
  describe '#generate_account_key' do
    let(:email) { 'user@example.com' }
    let(:key) { '72ae25495a7981c40622d49f9a52e4f1565c90f048f59027bd9c8c8900d5c3d8' }

    context 'successful request' do
      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: true, parsed_response: { 'account_key' => 'b97df97988a3832f009e2f18663ac932' }))
      end

      it 'returns the account key' do
        service = AccessKeyService.new(email, key)
        expect(service.generate_account_key).to eq('b97df97988a3832f009e2f18663ac932')
      end
    end

    context 'failed request' do
      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: false))
      end

      it 'raises a StandardError' do
        service = AccessKeyService.new(email, key)
        expect { service.generate_account_key }.to raise_error(StandardError, 'Failed to retrieve account key')
      end
    end
  end
end
