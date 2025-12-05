# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ReturnBookService) do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book) { create(:book, total_copies: 2) }
  let(:borrowing) { create(:borrowing, user: member, book:, status: :active) }

  describe '#call' do
    subject(:service) { described_class.new(borrowing:, librarian:) }

    context 'when the return is successful' do
      it 'updates the borrowing status to returned' do
        service.call
        expect(borrowing.reload).to(be_returned)
      end

      it 'sets returned_at timestamp' do
        freeze_time do
          service.call
          expect(borrowing.reload.returned_at).to(eq(Time.current))
        end
      end

      it 'returns a successful result' do
        result = service.call
        expect(result).to(be_success)
      end

      it 'returns the updated borrowing in the result' do
        result = service.call
        expect(result.borrowing).to(be_a(Borrowing))
        expect(result.borrowing).to(be_returned)
      end
    end

    context 'when the borrowing is has already been returned' do
      let(:borrowing) { create(:borrowing, :returned, user: member, book:) }

      it 'returns a failure result' do
        result = service.call
        expect(result).to(be_failure)
      end

      it 'includes an error message' do
        result = service.call
        expect(result.error).to(include('has already been returned'))
      end
    end

    context 'when librarian is actually a member' do
      let(:librarian) { create(:user, :member) }

      it 'still processes the return (authorization is handled by policy)' do
        result = service.call
        expect(result).to(be_success)
      end
    end

    context 'when there is a database error' do
      before do
        allow(borrowing).to(receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(borrowing)))
      end

      it 'returns a failure result' do
        result = service.call
        expect(result).to(be_failure)
      end
    end
  end

  describe 'book availability after return' do
    let(:book) { create(:book, :kept, total_copies: 1) }
    let(:borrowing) { create(:borrowing, :active, user: member, book:) }

    it 'makes the book available again after return' do
      # Ensure borrowing is created and book is reloaded
      borrowing
      book.reload
      expect(book).not_to(be_available)

      described_class.new(borrowing:, librarian:).call

      expect(book.reload).to(be_available)
    end
  end
end
