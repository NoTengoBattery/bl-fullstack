# frozen_string_literal: true

# Base blueprint class for all serializers
# Provides common configuration and helper methods
class ApplicationBlueprint < Blueprinter::Base
  # Default identifier for all blueprints
  identifier :id

  # Helper method to format datetime to ISO 8601 for JavaScript consumption
  def self.datetime_field(name, options = {})
    field(name, **options) do |object, _options|
      value = object.send(name)
      value&.iso8601
    end
  end

  # Helper method to format date to ISO 8601 for JavaScript consumption
  def self.date_field(name, options = {})
    field(name, **options) do |object, _options|
      value = object.send(name)
      value&.iso8601
    end
  end
end
