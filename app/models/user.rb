# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  # Enums
  enum :role, { member: 0, librarian: 1 }, default: :member

  # Associations
  has_many :borrowings, dependent: :restrict_with_error

  # Validations
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create, length: { minimum: 6 }

  # Normalizations
  normalizes :email_address, with: ->(email) { email.strip.downcase }
end
