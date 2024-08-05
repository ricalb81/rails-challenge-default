require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe 'GET /api/users' do
    before do
      @user = create(:user)
    end

    let(:users) { JSON.parse(response.body)['users'] }
    let(:errors) { JSON.parse(response.body)['errors'] }

    it 'returns all users' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(users).to eq([{
                             'email' => @user.email,
                             'phone_number' => @user.phone_number,
                             'full_name' => @user.full_name,
                             'key' => @user.key,
                             'account_key' => @user.account_key,
                             'metadata' => @user.metadata
                           }])
    end

    it 'returns filtered users by email' do
      get :index, params: { email: @user.email }
      expect(response).to have_http_status(:ok)
      expect(users).to eq([{
                             'email' => @user.email,
                             'phone_number' => @user.phone_number,
                             'full_name' => @user.full_name,
                             'key' => @user.key,
                             'account_key' => @user.account_key,
                             'metadata' => @user.metadata
                           }])
    end
  end

  describe 'POST /api/users' do
    let(:errors) { JSON.parse(response.body)['errors'] }
    it 'creates a new user' do
      post :create, params: {
        user: {
          email: 'new@example.com',
          phone_number: '1234567890',
          full_name: 'New User',
          password: 'password',
          metadata: 'some metadata'
        }
      }
      expect(response).to have_http_status(:created)
      expect(User.count).to eq(1)
      expect(errors).to be_nil
    end

    it 'returns errors for invalid data' do
      post :create, params: { user: { email: '', phone_number: '1234567890123456789012345' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(errors).to be_present
      expect(errors).to include('Password is missing')
      expect(errors).to include('Email is missing')
      expect(errors).to include('Phone number is too long')
      expect(errors).to include('Password is missing')
    end
  end
end
