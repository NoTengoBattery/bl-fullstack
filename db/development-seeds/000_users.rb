# frozen_string_literal: true

require_relative '../seed_helper'

seed_model(model: 'User', times: 1) do |user|
  user.email_address = 'demo@example.com'
  user.password = user.password_confirmation = 'password'
end

seed_model(model: 'User', times: 10)
