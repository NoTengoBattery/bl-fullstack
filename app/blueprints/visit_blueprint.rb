# frozen_string_literal: true

# Serializer for Visit model
class VisitBlueprint < ApplicationBlueprint
  fields :ip_address

  datetime_field :created_at
end
