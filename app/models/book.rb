# frozen_string_literal: true

# Represents a book in the library system.
# Supports soft deletion and availability tracking.
class Book < ApplicationRecord
  include Discard::Model

  # Associations
  has_many :borrowings, dependent: :restrict_with_error

  # Validations
  validates :title, presence: true
  validates :author, presence: true
  validates :total_copies, presence: true,
                           numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :isbn, uniqueness: { case_sensitive: false },
                   format: { with: /\A(?:\d{9}X|\d{10}|\d{13})\z/, message: 'must be a valid ISBN-10 or ISBN-13' }, allow_blank: true
  validate :total_copies_cannot_decrease_below_borrowed_count

  # Scopes
  scope :search_by_term, lambda { |term|
    return all if term.blank?

    sanitized_term = sanitize_sql_like(term)
    where(
      'title ILIKE :term OR author ILIKE :term OR genre ILIKE :term',
      term: "%#{sanitized_term}%"
    )
  }

  # Instance Methods

  # Calculates availability dynamically without counter cache
  # A book is available if it has more total copies than active borrowings
  def available? = available_copies.positive?

  # Returns the number of copies currently available for borrowing
  def available_copies = total_copies - borrowings.active.count

  # Custom method to check if book can be deleted
  def can_be_deleted?
    borrowings.active.none?
  end

  private

  def total_copies_cannot_decrease_below_borrowed_count
    return if total_copies.blank? || !total_copies_changed? || new_record?

    borrowed_count = borrowings.active.count
    previous_total = total_copies_was

    return unless total_copies < previous_total && total_copies < borrowed_count

    errors.add(:total_copies,
               "cannot be decreased below the number of currently borrowed copies (#{borrowed_count} active borrowings)")
  end
end
