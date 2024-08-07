class GenerateAccountKeyJob
  include Sidekiq::Job

  sidekiq_options retry: 5, backoff: :exponential

  def perform(user_id)
    user = User.find(user_id)
    account_key = AccessKeyService.new(user.email, user.key).generate_account_key
    user.account_key = account_key
    user.save(validate: false)

  rescue ActiveRecord::RecordNotFound
    # Handle the case where the user does not exist
    Rails.logger.error("User with ID #{user_id} not found")
  rescue StandardError => exception
    Rails.logger.error(exception.message)
  end
end
