# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Registrations') do
  describe 'GET /register' do
    it 'renders the registration page' do
      get '/register'

      expect(response).to(have_http_status(:ok))
      expect(inertia_component).to(eq('auth/register'))
    end

    context 'when already authenticated' do
      let(:user) { create(:user_spec) }

      before { sign_in_as(user) }

      it 'redirects to home' do
        get '/register'

        expect(response).to(redirect_to('/'))
      end
    end
  end

  describe 'POST /register' do
    let(:valid_params) do
      {
        email_address: 'newuser@test.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    context 'with valid params' do
      it 'creates a new user' do
        expect do
          post('/register', params: valid_params)
        end.to(change(User, :count).by(1))
      end

      it 'logs in the user and redirects to home' do
        post '/register', params: valid_params

        expect(response).to(redirect_to('/'))
      end

      it 'sets flash notice' do
        post '/register', params: valid_params

        follow_redirect!
        expect(flash[:notice]).to(eq('Account created successfully.'))
      end
    end

    context 'with invalid params' do
      it 'does not create user with invalid email' do
        expect do
          post('/register', params: valid_params.merge(email_address: 'invalid'))
        end.not_to(change(User, :count))
      end

      it 'does not create user with short password' do
        expect do
          post('/register', params: valid_params.merge(password: '12345', password_confirmation: '12345'))
        end.not_to(change(User, :count))
      end

      it 'does not create user with mismatched passwords' do
        expect do
          post('/register', params: valid_params.merge(password_confirmation: 'different'))
        end.not_to(change(User, :count))
      end

      it 'does not create user with existing email' do
        create(:user_spec, email_address: 'newuser@test.com')

        expect do
          post('/register', params: valid_params)
        end.not_to(change(User, :count))
      end

      it 'redirects back with errors' do
        post '/register', params: valid_params.merge(email_address: 'invalid')

        expect(response).to(redirect_to('/register'))
      end
    end
  end
end
