# frozen_string_literal: true

# Represents a book borrowing record.
# Tracks active and returned borrowings with due dates.
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
  validate :book_has_available_copies, on: :create
  validate :user_has_no_overdue_borrowings, on: :create

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

  def book_has_available_copies
    return unless book
    return if book.available_copies.positive?

    errors.add(:book, 'has no available copies')
  end

  def user_has_no_overdue_borrowings
    return unless user
    return if user.borrowings.overdue.none?

    errors.add(:base, 'Cannot borrow books while you have overdue borrowings')
  end
end
