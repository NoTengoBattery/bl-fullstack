# frozen_string_literal: true

module AuthenticationHelper
  def sign_in(user)
    post('/login', params: { email_address: user.email_address, password: 'testpass' })
  end

  def sign_out
    delete('/logout')
  end

  # For request specs that need to set up session directly
  def sign_in_as(user)
    # Create a session by calling login
    sign_in(user)
    follow_redirect! if response.redirect?
  end
end

RSpec.configure do |config|
  config.include(AuthenticationHelper, type: :request)
end
