require 'rails_helper'

RSpec.describe Api::UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/users').to route_to('api/users#index')
    end

    it 'routes to #create' do
      expect(post: '/api/users').to route_to('api/users#create')
    end
  end
end
