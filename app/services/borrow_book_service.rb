# frozen_string_literal: true

# Service object for borrowing a book
# Handles eligibility checks, availability verification, and concurrency via optimistic locking
#
# @example
#   result = BorrowBookService.new(user: user, book: book).call
#   if result.success?
#     puts "Book borrowed successfully: #{result.borrowing.id}"
#   else
#     puts "Error: #{result.error}"
#   end
#
class BorrowBookService
  Result = Struct.new(:success, :borrowing, :error, keyword_init: true) do
    def success? = success

    def failure? = !success
  end

  def initialize(user:, book:)
    @user = user
    @book = book
  end

  def call
    validate_eligibility!
    validate_availability!

    borrowing = create_borrowing

    Result.new(success: true, borrowing:)
  rescue EligibilityError, AvailabilityError => e
    Result.new(success: false, error: e.message)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success: false, error: e.record.errors.full_messages.join(', '))
  rescue ActiveRecord::StaleObjectError
    Result.new(success: false, error: 'The book was modified by another process. Please try again.')
  end

  private

  attr_reader :user, :book

  class EligibilityError < StandardError; end

  class AvailabilityError < StandardError; end

  def validate_eligibility!
    raise(EligibilityError, 'User already has an active borrowing for this book') if user_already_borrowed_book?
  end

  def validate_availability!
    raise(AvailabilityError, 'Book is not available') unless book_available?
  end

  def user_already_borrowed_book? = Borrowing.exists?(user:, book:, returned_at: nil)

  def book_available? = book.kept? && book.available?

  def create_borrowing
    Borrowing.create!(
      user:,
      book:,
      borrowed_at: Time.current,
      due_on: 2.weeks.from_now.to_date,
      status: :active
    )
  end
end
