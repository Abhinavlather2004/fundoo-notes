require 'rails_helper'

RSpec.describe 'User Authentication', type: :request do
  let(:valid_user_params) do
    {
      user: {
        name: "Test User",
        email: "test@example.com",
        mobile_number: "+91-7656765676",
        password: "Password@123"
      }
    }
  end

  describe 'POST /api/v1/users' do
    it 'registers a new user successfully' do
      post '/api/v1/users', params: valid_user_params, as: :json

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['email']).to eq(valid_user_params[:user][:email])
    end

    it 'fails to register a user with invalid data' do
      invalid_params = { user: { name: "Test User", email: "", password: "Password@123" } }
      post '/api/v1/users', params: invalid_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('errors')
    end
  end

  describe 'POST /api/v1/users/login' do
    let!(:user) { User.create!(valid_user_params[:user]) }

    it 'logs in a user successfully' do
      login_params = { user: { email: "test@example.com", password: "Password@123" } }
      post '/api/v1/users/login', params: login_params, as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Login successful')
      expect(json_response).to have_key('token')
    end

    it 'fails login with incorrect password' do
      login_params = { user: { email: "test@example.com", password: "wrongpassword" } }
      post '/api/v1/users/login', params: login_params, as: :json

      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Invalid password')
    end
  end
end
