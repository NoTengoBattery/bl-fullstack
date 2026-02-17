# frozen_string_literal: true

# Controller for user registration.
# Handles new user account creation.
class RegistrationsController < ApplicationController
  # Skip authentication for registration pages
  before_action :redirect_if_authenticated

  def new
    render(inertia: 'auth/register')
  end

  def create
    user = User.new(registration_params)

    if user.save
      session[:user_id] = user.id
      redirect_to(root_path, notice: 'Account created successfully.')
    else
      redirect_to(register_path, inertia: { errors: user.errors.to_hash })
    end
  end

  private

  def registration_params
    params.permit(:email_address, :password, :password_confirmation)
  end

  def redirect_if_authenticated
    redirect_to(root_path, notice: 'You are already logged in.') if current_user
  end
end
