# frozen_string_literal: true

# Service object for returning a borrowed book
# Handles the return process by updating the borrowing status and timestamp
#
# @example
#   result = ReturnBookService.new(borrowing: borrowing, librarian: librarian).call
#   if result.success?
#     puts "Book returned successfully"
#   else
#     puts "Error: #{result.error}"
#   end
#
class ReturnBookService
  Result = Struct.new(:success, :borrowing, :error, keyword_init: true) do
    def success? = success
    def failure? = !success
  end

  def initialize(borrowing:, librarian:)
    @borrowing = borrowing
    @librarian = librarian
  end

  def call
    validate_borrowing_status!

    update_borrowing

    Result.new(success: true, borrowing:)
  rescue AlreadyReturnedError => e
    Result.new(success: false, error: e.message)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success: false, error: e.record.errors.full_messages.join(', '))
  end

  private

  attr_reader :borrowing, :librarian

  class AlreadyReturnedError < StandardError; end

  def validate_borrowing_status!
    raise(AlreadyReturnedError, 'This book has already been returned') if borrowing.returned?
  end

  def update_borrowing = borrowing.update!(returned_at: Time.current, status: :returned)
end
