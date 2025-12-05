# frozen_string_literal: true

class Book < ApplicationRecord
  include Discard::Model

  # Associations
  has_many :borrowings, dependent: :restrict_with_error

  # Validations
  validates :title, presence: true
  validates :author, presence: true
  validates :total_copies, presence: true,
                           numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :isbn, uniqueness: { case_sensitive: false }, allow_nil: true

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
end
