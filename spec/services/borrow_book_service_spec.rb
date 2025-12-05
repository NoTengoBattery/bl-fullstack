# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(BorrowBookService) do
  let(:user) { create(:user, :member) }
  let(:book) { create(:book, :kept, total_copies: 2) }

  describe '#call' do
    subject(:service) { described_class.new(user:, book:) }

    context 'when the borrow is successful' do
      it 'creates a new borrowing' do
        expect { service.call }.to(change(Borrowing, :count).by(1))
      end

      it 'returns a successful result' do
        result = service.call
        expect(result).to(be_success)
      end

      it 'returns the borrowing in the result' do
        result = service.call
        expect(result.borrowing).to(be_a(Borrowing))
        expect(result.borrowing).to(be_persisted)
      end

      it 'creates an active borrowing' do
        result = service.call
        expect(result.borrowing).to(be_active)
      end

      it 'sets the correct due date (2 weeks from now)' do
        result = service.call
        expect(result.borrowing.due_on).to(eq(2.weeks.from_now.to_date))
      end

      it 'associates the borrowing with the correct user and book' do
        result = service.call
        expect(result.borrowing.user).to(eq(user))
        expect(result.borrowing.book).to(eq(book))
      end
    end

    context 'when the user already has an active borrowing for the book' do
      before do
        create(:borrowing, :active, user:, book:)
      end

      it 'does not create a new borrowing' do
        expect { service.call }.not_to(change(Borrowing, :count))
      end

      it 'returns a failure result' do
        result = service.call
        expect(result).to(be_failure)
      end

      it 'includes an error message' do
        result = service.call
        expect(result.error).to(include('already'))
      end
    end

    context 'when the book is not available (all copies borrowed)' do
      before do
        book.total_copies.times do |i|
          create(:borrowing, :active, book:, user: create(:user, :member, email_address: "other#{i}@example.com"))
        end
      end

      it 'does not create a new borrowing' do
        expect { service.call }.not_to(change(Borrowing, :count))
      end

      it 'returns a failure result' do
        result = service.call
        expect(result).to(be_failure)
      end

      it 'includes an availability error message' do
        result = service.call
        expect(result.error).to(include('available'))
      end
    end

    context 'when the book is discarded (soft deleted)' do
      let(:book) { create(:book, :discarded, total_copies: 5) }

      it 'does not create a new borrowing' do
        expect { service.call }.not_to(change(Borrowing, :count))
      end

      it 'returns a failure result' do
        result = service.call
        expect(result).to(be_failure)
      end

      it 'includes a discarded error message' do
        result = service.call
        expect(result.error).to(include('available'))
      end
    end

    context 'with optimistic locking (concurrent access)' do
      let(:book) { create(:book, total_copies: 1) }

      it 'handles StaleObjectError gracefully' do
        # Simulate a stale object scenario
        stale_book = Book.find(book.id)

        # First user borrows the book
        first_service = described_class.new(user:, book:)
        first_service.call

        # Second user tries to borrow with stale data
        second_user = create(:user, email_address: 'second@example.com')
        second_service = described_class.new(user: second_user, book: stale_book)
        result = second_service.call

        # Should fail gracefully since book is no longer available
        expect(result).to(be_failure)
      end
    end
  end
end
