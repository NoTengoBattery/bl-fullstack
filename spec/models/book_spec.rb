# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Book) do
  describe 'validations' do
    subject(:book) { build(:book) }

    it { is_expected.to(validate_presence_of(:title)) }
    it { is_expected.to(validate_presence_of(:author)) }
    it { is_expected.to(validate_presence_of(:total_copies)) }
    it { is_expected.to(validate_numericality_of(:total_copies).only_integer.is_greater_than_or_equal_to(0)) }
    it { is_expected.to(validate_uniqueness_of(:isbn).case_insensitive.allow_nil) }

    describe 'ISBN format validation' do
      it 'accepts valid ISBN-10' do
        book.isbn = '0306406152'
        expect(book).to(be_valid)
      end

      it 'accepts valid ISBN-10 with X check digit' do
        book.isbn = '043942089X'
        expect(book).to(be_valid)
      end

      it 'accepts valid ISBN-13' do
        book.isbn = '9780306406157'
        expect(book).to(be_valid)
      end

      it 'rejects invalid ISBN format' do
        book.isbn = '123'
        expect(book).not_to(be_valid)
        expect(book.errors[:isbn]).to(include(match(/must be a valid ISBN/)))
      end

      it 'rejects ISBN with invalid characters' do
        book.isbn = '03064061XX'
        expect(book).not_to(be_valid)
      end

      it 'allows nil ISBN' do
        book.isbn = nil
        expect(book).to(be_valid)
      end

      it 'allows blank ISBN' do
        book.isbn = ''
        expect(book).to(be_valid)
      end
    end

    describe 'total_copies cannot decrease below borrowed count' do
      let(:book) { create(:book, total_copies: 5) }

      context 'when decreasing copies below active borrowings' do
        before do
          3.times { create(:borrowing, :active, book:, user: create(:user, :member)) }
        end

        it 'rejects the update' do
          book.total_copies = 2
          expect(book).not_to(be_valid)
          expect(book.errors[:total_copies]).to(include(match(/cannot be decreased below/)))
        end

        it 'allows keeping copies at current level' do
          book.total_copies = 5
          expect(book).to(be_valid)
        end

        it 'allows increasing copies' do
          book.total_copies = 10
          expect(book).to(be_valid)
        end
      end

      context 'when no borrowings exist' do
        it 'allows decreasing to zero' do
          book.total_copies = 0
          expect(book).to(be_valid)
        end

        it 'allows any decrease' do
          book.total_copies = 2
          expect(book).to(be_valid)
        end
      end

      context 'when only returned borrowings exist' do
        before do
          2.times { create(:borrowing, :returned, book:, user: create(:user, :member)) }
        end

        it 'allows decreasing copies (returned books do not count)' do
          book.total_copies = 1
          expect(book).to(be_valid)
        end
      end

      context 'when on initial creation' do
        let(:new_book) { build(:book, total_copies: 10) }

        it 'does not validate against borrowed count' do
          expect(new_book).to(be_valid)
        end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to(have_many(:borrowings).dependent(:restrict_with_error)) }
  end

  describe 'soft deletes' do
    let(:book) { create(:book, :kept) }

    it 'supports soft delete with discard' do
      expect(book).to(respond_to(:discard))
      expect(book).to(respond_to(:discarded?))
      expect(book).to(respond_to(:undiscard))
    end

    it 'is not discarded by default' do
      expect(book).not_to(be_discarded)
    end

    it 'can be discarded' do
      book.discard
      expect(book).to(be_discarded)
      expect(book.discarded_at).to(be_present)
    end

    it 'can be undiscarded' do
      book.discard
      book.undiscard
      expect(book).not_to(be_discarded)
    end

    it 'scopes kept records by default' do
      kept_book = create(:book, :kept)
      discarded_book = create(:book, :kept)
      discarded_book.discard

      expect(described_class.kept).to(include(kept_book))
      expect(described_class.kept).not_to(include(discarded_book))
    end
  end

  describe 'optimistic locking' do
    it 'has lock_version column' do
      book = create(:book)
      expect(book).to(respond_to(:lock_version))
      expect(book.lock_version).to(eq(0))
    end

    it 'increments lock_version on update' do
      book = create(:book)
      initial_version = book.lock_version

      book.update!(title: 'Updated Title')
      expect(book.lock_version).to(eq(initial_version + 1))
    end

    it 'raises StaleObjectError on concurrent updates' do
      book = create(:book)
      book_copy = described_class.find(book.id)

      book.update!(title: 'First Update')

      expect do
        book_copy.update!(title: 'Concurrent Update')
      end.to(raise_error(ActiveRecord::StaleObjectError))
    end
  end

  describe '#available?' do
    let(:book) { create(:book, total_copies: 2) }
    let(:user) { create(:user) }

    context 'when no books are borrowed' do
      it 'returns true' do
        expect(book).to(be_available)
      end
    end

    context 'when some copies are borrowed but not all' do
      before do
        create(:borrowing, book:, user:, status: :active)
      end

      it 'returns true' do
        expect(book).to(be_available)
      end
    end

    context 'when all copies are borrowed' do
      before do
        book.total_copies.times do
          create(:borrowing, :active, book:, user: create(:user, :member))
        end
      end

      it 'returns false' do
        expect(book).not_to(be_available)
      end
    end

    context 'when returned borrowings exist' do
      before do
        book.total_copies.times do
          create(:borrowing, :returned, book:, user: create(:user, :member))
        end
      end

      it 'returns true (returned books are available)' do
        expect(book).to(be_available)
      end
    end
  end

  describe '#available_copies' do
    let(:book) { create(:book, total_copies: 5) }

    context 'when no books are borrowed' do
      it 'returns total_copies' do
        expect(book.available_copies).to(eq(5))
      end
    end

    context 'when some copies are borrowed' do
      before do
        3.times { create(:borrowing, :active, book:, user: create(:user, :member)) }
      end

      it 'returns the difference' do
        expect(book.available_copies).to(eq(2))
      end
    end
  end

  describe '#can_be_deleted?' do
    let(:book) { create(:book) }

    context 'when book has no borrowings' do
      it 'returns true' do
        expect(book.can_be_deleted?).to(be(true))
      end
    end

    context 'when book has only active borrowings' do
      before do
        create(:borrowing, :active, book:, user: create(:user, :member))
      end

      it 'returns false' do
        expect(book.can_be_deleted?).to(be(false))
      end
    end

    context 'when book has multiple active borrowings' do
      before do
        2.times { create(:borrowing, :active, book:, user: create(:user, :member)) }
      end

      it 'returns false' do
        expect(book.can_be_deleted?).to(be(false))
      end
    end

    context 'when book has only returned borrowings' do
      before do
        create(:borrowing, :returned, book:, user: create(:user, :member))
      end

      it 'returns true' do
        expect(book.can_be_deleted?).to(be(true))
      end
    end

    context 'when book has both active and returned borrowings' do
      before do
        create(:borrowing, :active, book:, user: create(:user, :member))
        create(:borrowing, :returned, book:, user: create(:user, :member))
      end

      it 'returns false (due to active borrowing)' do
        expect(book.can_be_deleted?).to(be(false))
      end
    end
  end

  describe '.search_by_term' do
    let!(:fiction_book) { create(:book, title: 'The Great Adventure', author: 'John Smith', genre: 'Fiction') }
    let!(:science_book) { create(:book, title: 'Physics 101', author: 'Jane Doe', genre: 'Science') }
    let!(:mystery_book) { create(:book, title: 'Murder Mystery', author: 'Agatha Smith', genre: 'Mystery') }

    it 'searches by title' do
      results = described_class.search_by_term('Adventure')
      expect(results).to(include(fiction_book))
      expect(results).not_to(include(science_book))
    end

    it 'searches by author' do
      results = described_class.search_by_term('Smith')
      expect(results).to(include(fiction_book, mystery_book))
      expect(results).not_to(include(science_book))
    end

    it 'searches by genre' do
      results = described_class.search_by_term('Science')
      expect(results).to(include(science_book))
      expect(results).not_to(include(fiction_book))
    end

    it 'is case insensitive' do
      results = described_class.search_by_term('FICTION')
      expect(results).to(include(fiction_book))
    end

    it 'handles partial matches with trigram similarity' do
      results = described_class.search_by_term('Adven')
      expect(results).to(include(fiction_book))
    end

    it 'returns all records when term is blank' do
      results = described_class.search_by_term('')
      expect(results.count).to(eq(3))
    end

    it 'returns all records when term is nil' do
      results = described_class.search_by_term(nil)
      expect(results.count).to(eq(3))
    end
  end
end
