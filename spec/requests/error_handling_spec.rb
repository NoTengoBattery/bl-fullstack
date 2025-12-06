# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Error Handling') do
  describe 'GET /books/:id with invalid id' do
    it 'renders the 404 page with not_found status' do
      get '/books/99999'
      expect(response).to(have_http_status(:not_found))
    end
  end

  describe 'GET /borrowings/:id with invalid id' do
    let(:user) { create(:user_spec, :member) }

    before do
      sign_in_as(user)
    end

    it 'renders the 404 page' do
      get '/borrowings/99999'
      expect(response).to(have_http_status(:not_found))
    end
  end
end
