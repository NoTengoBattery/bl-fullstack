# frozen_string_literal: true

# Serializer for User model
# Exposes only safe fields - never includes password_digest
class UserBlueprint < ApplicationBlueprint
  # Default view - minimal user info
  fields :email_address, :role

  datetime_field :created_at
  datetime_field :updated_at

  # Extended view with additional details
  view :extended do
    field :borrowings_count do |user, _options|
      user.borrowings.active.count
    end
  end

  # Minimal view for embedding in other resources
  view :minimal do
    excludes :created_at, :updated_at
  end
end
