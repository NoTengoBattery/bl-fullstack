# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Sessions') do
  let(:user) { create(:user_spec, :member) }

  describe 'GET /login' do
    it 'renders the login page' do
      get '/login'

      expect(response).to(have_http_status(:ok))
      expect(inertia_component).to(eq('auth/login'))
    end

    context 'when already authenticated' do
      before { sign_in_as(user) }

      it 'redirects to dashboard' do
        get '/login'

        expect(response).to(redirect_to('/dashboard'))
      end
    end
  end

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'logs in the user' do
        post '/login', params: { email_address: user.email_address, password: 'testpass' }

        expect(response).to(redirect_to('/dashboard'))
      end

      it 'sets flash notice' do
        post '/login', params: { email_address: user.email_address, password: 'testpass' }

        follow_redirect!
        expect(flash[:notice]).to(eq('Successfully logged in.'))
      end
    end

    context 'with invalid credentials' do
      it 'redirects back to login with alert' do
        post '/login', params: { email_address: user.email_address, password: 'wrongpass' }

        expect(response).to(redirect_to('/login'))
        follow_redirect!
        expect(flash[:alert]).to(eq('Invalid email or password.'))
      end

      it 'does not log in with non-existent email' do
        post '/login', params: { email_address: 'nonexistent@test.com', password: 'testpass' }

        expect(response).to(redirect_to('/login'))
      end
    end
  end

  describe 'DELETE /logout' do
    before { sign_in_as(user) }

    it 'logs out the user' do
      delete '/logout'

      expect(response).to(redirect_to('/'))
    end

    it 'sets flash notice' do
      delete '/logout'

      follow_redirect!
      expect(flash[:notice]).to(eq('Successfully logged out.'))
    end

    it 'clears the session' do
      delete '/logout'

      # Verify user is logged out by accessing protected route
      get '/dashboard'
      expect(response).to(redirect_to('/login'))
    end
  end
end
