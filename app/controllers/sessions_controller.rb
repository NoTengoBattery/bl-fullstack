# frozen_string_literal: true

# Controller for user authentication sessions.
# Handles login and logout functionality.
class SessionsController < ApplicationController
  # Skip authentication for login pages
  before_action :redirect_if_authenticated, only: %i[new create]

  def new
    render(inertia: 'auth/login')
  end

  def create
    user = User.find_by(email_address: params[:email_address]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      Visit.create(user: user, ip_address: request.remote_ip)
      redirect_to(root_path, notice: 'Successfully logged in.')
    else
      redirect_to(login_path, alert: 'Invalid email or password.')
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    redirect_to(root_path, notice: 'Successfully logged out.')
  end

  private

  def redirect_if_authenticated
    redirect_to(root_path, notice: 'You are already logged in.') if current_user
  end
end
