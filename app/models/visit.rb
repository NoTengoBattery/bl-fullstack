# frozen_string_literal: true

# Records each user login for tracking purposes.
class Visit < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :ip_address, presence: true
end
