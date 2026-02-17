# frozen_string_literal: true

# Represents a user in the application.
class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :visits, dependent: :delete_all

  # Validations
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create, length: { minimum: 6 }

  # Normalizations
  normalizes :email_address, with: ->(email) { email.strip.downcase }
end
