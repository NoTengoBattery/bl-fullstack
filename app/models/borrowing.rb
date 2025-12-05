# frozen_string_literal: true

class Borrowing < ApplicationRecord
  # Enums
  enum :status, { active: 0, returned: 1 }, default: :active

  # Associations
  belongs_to :user
  belongs_to :book

  # Validations
  validates :due_on, presence: true
  validates :borrowed_at, presence: true
  validate :unique_active_borrowing, on: :create

  # Scopes
  scope :active, -> { where(status: :active, returned_at: nil) }
  scope :overdue, -> { active.where(due_on: ...Date.current) }

  # Callbacks
  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.borrowed_at ||= Time.current
    self.due_on ||= 2.weeks.from_now.to_date
  end

  def unique_active_borrowing
    return unless user_id && book_id

    existing = Borrowing.exists?(user_id:, book_id:, returned_at: nil)
    return unless existing

    errors.add(:base, 'User already has an active borrowing for this book')
  end
end
