class AccessKeyService

  URL_ACCOUNT_KEY = 'https://w7nbdj3b3nsy3uycjqd7bmuplq0yejgw.lambda-url.us-east-2.on.aws/v2/account'

  def initialize(email, key)
    @email = email
    @key = key
  end

  def generate_account_key
    response = HTTParty.post(
      URL_ACCOUNT_KEY,
      body: { email: @email, key: @key }.to_json,
      headers: { 'Content-Type': 'application/json' }
    )
    raise StandardError, 'Failed to retrieve account key' unless response.success? && response.parsed_response.present?
    response.parsed_response['account_key']
  end
end
