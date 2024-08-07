class GenerateKeysJob
  include Sidekiq::Job

  def perform
    users_without_account = User.where(:account_key => nil)
    users_without_account.each do |user|
      GenerateAccountKeyJob.perform_async(user.id)
    end
  end
end
