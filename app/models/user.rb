class User < ApplicationRecord
  has_secure_password
  attr_accessor :skip_callbacks

  validates :email, presence: true, uniqueness: true, length: { maximum: 200 }
  validates :phone_number, presence: true, uniqueness: true, length: { maximum: 20 }
  validates :full_name, length: { maximum: 200 }, allow_blank: true
  validates :password, presence: true, length: { maximum: 100 }
  validates :key, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :account_key, uniqueness: true, length: { maximum: 100 }, allow_blank: true
  validates :metadata, length: { maximum: 2000 }, allow_blank: true

  before_validation :generate_key, on: :create, unless: :skip_callbacks?

  after_create do
    GenerateAccountKeyJob.new.perform(id)
  end

  private

  def skip_callbacks?
    skip_callbacks
  end

  def generate_key
    self.key = SecureRandom.hex(32)
  end
end
