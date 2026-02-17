# frozen_string_literal: true

# Base controller for all application controllers.
# Provides authentication, authorization, and shared Inertia configuration.
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pundit authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Handle 404 - Record Not Found
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  # Handle optimistic locking conflicts
  rescue_from ActiveRecord::StaleObjectError, with: :handle_stale_object

  # Inertia configuration
  inertia_config default_render: true

  # Shared props available to all Inertia pages
  inertia_share do
    {
      auth: current_user_props,
      flash: flash.to_hash
    }
  end

  private

  # Authentication helpers
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    return if current_user

    redirect_to(login_path, alert: 'You must be logged in to access this page.')
  end

  def current_user_props
    return nil unless current_user

    UserBlueprint.render_as_hash(current_user, view: :minimal)
  end

  # Authorization helpers
  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_back_or_to(root_path)
  end

  # Optimistic locking handler
  def handle_stale_object
    flash[:alert] = 'The record was modified by someone else. Please try again.'
    redirect_back_or_to(root_path)
  end

  # 404 Not Found handler
  def handle_not_found
    render(inertia: 'errors/not_found', status: :not_found)
  end
end
