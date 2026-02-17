# frozen_string_literal: true

# Serializer for User model
# Exposes only safe fields - never includes password_digest
class UserBlueprint < ApplicationBlueprint
  # Default view - user info
  fields :email_address

  datetime_field :created_at
  datetime_field :updated_at

  # Minimal view for embedding in other resources
  view :minimal do
    excludes :created_at, :updated_at
  end
end
