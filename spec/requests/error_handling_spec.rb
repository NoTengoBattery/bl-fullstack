# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Error Handling') do
  describe 'GET /nonexistent-path' do
    it 'renders the 404 page with not_found status' do
      get '/nonexistent-path'
      expect(response).to(have_http_status(:not_found))
    end
  end
end
