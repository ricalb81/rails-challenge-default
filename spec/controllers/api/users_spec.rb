require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe 'GET /api/users' do
    before do
      @users = []
      2.times do |i|
        account_key = SecureRandom.hex(32)
        allow_any_instance_of(AccessKeyService).to receive(:generate_account_key).and_return(account_key)
        @users << create(:user, full_name: "User #{i}")
      end

      # Different Name
      account_key = SecureRandom.hex(32)
      allow_any_instance_of(AccessKeyService).to receive(:generate_account_key).and_return(account_key)
      @users << create(:user, full_name: "John Doe")
    end

    let(:users) { JSON.parse(response.body)['users'] }
    let(:errors) { JSON.parse(response.body)['errors'] }
    let(:user1) { @users[0].reload.as_json(only: Api::UsersController::FIELDS_TO_RETURN) }
    let(:user2) { @users[1].reload.as_json(only: Api::UsersController::FIELDS_TO_RETURN) }
    let(:user3) { @users[2].reload.as_json(only: Api::UsersController::FIELDS_TO_RETURN) }

    it 'returns all users' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(users).to include(user1)
      expect(users).to include(user2)
      expect(users).to include(user3)

      # Bring objects in order from newest to oldest
      expect(users).to eq([user3, user2, user1])
    end

    it 'returns filtered users by name' do
      get :index, params: { full_name: "User" }
      expect(response).to have_http_status(:ok)

      # Include objects with "User" in name
      expect(users).to include(user1)
      expect(users).to include(user2)

      # Do not include users with other names
      expect(users).not_to include(user3)

      # Bring objects in order from newest to oldest
      expect(users).to eq([user2, user1])
    end

    it 'returns unprocessable_entity status for unsearchable fields' do
      get :index, params: { password: "password" }
      expect(response).to have_http_status(:unprocessable_entity)

      # Bring objects in order from newest to oldest
      expect(errors).to be_present
      expect(errors).to eq(["Invalid query parameters"])
    end
  end

  describe 'POST /api/users' do
    before do
      @account_key = SecureRandom.hex(32)
      allow_any_instance_of(AccessKeyService).to receive(:generate_account_key).and_return(@account_key)
    end

    let(:errors) { JSON.parse(response.body)['errors'] }
    let(:valid_attributes) do
      {
        email: 'user@example.com',
        phone_number: '5551235555',
        full_name: 'Joe Smith',
        password: 'password',
        metadata: 'male, age 32, unemployed, college-educated'
      }
      end

    let(:invalid_attributes) do
      {
        email: 'user@example.com', # Duplicate email
        phone_number: '5551235555', # Duplicate phone number
        full_name: 'John Doe',
        password: 'password',
        metadata: 'male, age 25, employed, high school'
      }
      end

    it 'creates a new user' do
      post :create, params: {
        user: valid_attributes
      }
      expect(response).to have_http_status(:created)
      expect(User.count).to eq(1)
      expect(errors).to be_nil
    end

    it 'creates a new user with key generated server side' do
      post :create, params: { user: valid_attributes }
      user = User.find_by(email: 'user@example.com')

      expect(user).not_to be_nil
      expect(user.key).to be_present

      # Ensures that the key matches the expected format of a 64-character hexadecimal string.
      expect(user.key).to match(/\A[a-f0-9]{64}\z/)
    end

    it 'creates a new user with hashed password' do
      post :create, params: { user: valid_attributes }
      user = User.find_by(email: 'user@example.com')

      expect(user).not_to be_nil
      expect(user.authenticate('password')).to eq(user)
      expect(user.password_digest).not_to eq('password')

      # Ensures that the password is hashed using BCrypt, which typically starts with $2a$.
      expect(user.password_digest).to start_with('$2a$')
    end

    it 'returns unprocessable_entity status for non unique request' do
      post :create, params: {
        user: valid_attributes
      }
      post :create, params: {
        user: invalid_attributes
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.count).to eq(1)
      expect(errors).to be_present
      expect(errors).to include("Email has already been taken")
      expect(errors).to include("Phone number has already been taken")
    end

    it 'creates a new user with an account_key' do
      post :create, params: { user: valid_attributes }
      user = User.find_by(email: 'user@example.com')

      expect(user).not_to be_nil
      expect(user.account_key).to eq(@account_key)
    end

    it 'returns errors for invalid data' do
      post :create, params: { user: { email: '', phone_number: '1234567890123456789012345' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(errors).to be_present
      expect(errors).to include('Password is missing')
      expect(errors).to include('Email is missing')
      expect(errors).to include('Phone number is too long (maximum is 20 characters)')
      expect(errors).to include('Password is missing')
    end
  end
end
