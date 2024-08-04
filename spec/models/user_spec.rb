require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:email).is_at_most(200) }

    it { should validate_presence_of(:phone_number) }
    it { should validate_uniqueness_of(:phone_number) }
    it { should validate_length_of(:phone_number).is_at_most(20) }

    it { should validate_length_of(:full_name).is_at_most(200) }

    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_most(100) }

    it { should validate_uniqueness_of(:account_key) }
    it { should validate_length_of(:account_key).is_at_most(100) }

    it { should validate_length_of(:metadata).is_at_most(2000) }

    context "disable callback to check key validation rules" do
      before(:each) do
        allow_any_instance_of(User).to receive(:skip_callbacks?).and_return(true)
      end
      it { should validate_presence_of(:key) }
      it { should validate_uniqueness_of(:key) }
      it { should validate_length_of(:key).is_at_most(100) }
    end
  end

  describe 'callbacks' do
    context 'before_validation' do
      it 'generates a key before validation on create unless skip_callbacks is true' do
        user = User.new(email: 'test@example.com', phone_number: '1234567890', password: 'password')
        expect(user.key).to be_nil
        user.valid?
        expect(user.key).to be_present
      end

      it 'does not generate a key if skip_callbacks is true' do
        user = User.new(email: 'test@example.com', phone_number: '1234567890', password: 'password', skip_callbacks: true)
        expect(user.key).to be_nil
        user.valid?
        expect(user.key).to be_nil
      end
    end
  end
end
