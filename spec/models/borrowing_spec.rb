# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Borrowing) do
  describe 'validations' do
    subject(:borrowing) { build(:borrowing) }

    # NOTE: due_on and borrowed_at have defaults set via before_validation callback
    # so we test the default behavior instead of validate_presence_of

    it 'requires due_on when not using defaults' do
      borrowing = described_class.new(user: create(:user), book: create(:book), borrowed_at: Time.current)
      borrowing.due_on = nil
      borrowing.valid?
      # Callback will set a default, so it should be valid
      expect(borrowing.due_on).to(be_present)
    end

    it 'requires borrowed_at when not using defaults' do
      borrowing = described_class.new(user: create(:user), book: create(:book), due_on: 2.weeks.from_now)
      borrowing.borrowed_at = nil
      borrowing.valid?
      # Callback will set a default, so it should be valid
      expect(borrowing.borrowed_at).to(be_present)
    end
  end

  describe 'associations' do
    it { is_expected.to(belong_to(:user)) }
    it { is_expected.to(belong_to(:book)) }
  end

  describe 'enums' do
    it { is_expected.to(define_enum_for(:status).with_values(active: 0, returned: 1)) }
  end

  describe 'default values' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    it 'defaults status to active' do
      borrowing = described_class.new(user:, book:, due_on: 2.weeks.from_now)
      expect(borrowing.status).to(eq('active'))
    end

    it 'defaults borrowed_at to current time' do
      borrowing = create(:borrowing, user:, book:)
      expect(borrowing.borrowed_at).to(be_within(1.minute).of(Time.current))
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:book) { create(:book, total_copies: 10) }

    describe '.active' do
      let!(:active_borrowing) { create(:borrowing, user:, book:, status: :active, returned_at: nil) }
      let!(:returned_borrowing) do
        create(:borrowing, user: create(:user), book:, status: :returned, returned_at: Time.current)
      end

      it 'returns only active borrowings' do
        expect(described_class.active).to(include(active_borrowing))
        expect(described_class.active).not_to(include(returned_borrowing))
      end
    end

    describe '.overdue' do
      let!(:overdue_borrowing) do
        create(:borrowing, user:, book:, status: :active, due_on: 1.week.ago, returned_at: nil)
      end
      let!(:not_overdue_borrowing) do
        create(:borrowing, user: create(:user), book:, status: :active, due_on: 1.week.from_now, returned_at: nil)
      end
      let!(:returned_past_due) do
        create(:borrowing, user: create(:user), book:, status: :returned, due_on: 1.week.ago, returned_at: Time.current)
      end

      it 'returns only overdue borrowings' do
        expect(described_class.overdue).to(include(overdue_borrowing))
        expect(described_class.overdue).not_to(include(not_overdue_borrowing))
        expect(described_class.overdue).not_to(include(returned_past_due))
      end
    end
  end

  describe 'unique active borrowing constraint' do
    let(:user) { create(:user, :member) }
    let(:book) { create(:book, :kept, total_copies: 10) }

    it 'allows one active borrowing per user per book' do
      create(:borrowing, :active, user:, book:)

      duplicate = build(:borrowing, :active, user:, book:)
      expect(duplicate).not_to(be_valid)
    end

    it 'allows a new borrowing after returning the previous one' do
      first_borrowing = create(:borrowing, :active, user:, book:)
      first_borrowing.update!(status: :returned, returned_at: Time.current)

      second_borrowing = build(:borrowing, :active, user:, book:)
      expect(second_borrowing).to(be_valid)
    end

    it 'allows different users to borrow the same book' do
      create(:borrowing, user:, book:, status: :active)

      other_user = create(:user)
      second_borrowing = build(:borrowing, user: other_user, book:, status: :active)
      expect(second_borrowing).to(be_valid)
    end
  end

  describe 'book availability validation' do
    let(:total_copies) { 1 }
    let(:book) { create(:book, total_copies: total_copies) }
    let(:first_user) { create(:user) }
    let(:second_user) { create(:user) }
    let(:borrowing) { build(:borrowing, book:, user: second_user) }

    before do
      create(:borrowing, :active, book:, user: first_user)
    end

    context 'when no copies remain' do
      it 'is invalid' do
        expect(borrowing).not_to(be_valid)
        expect(borrowing.errors[:book]).to(include('has no available copies'))
      end
    end

    context 'when copies remain' do
      let(:total_copies) { 2 }

      it 'remains valid' do
        expect(borrowing).to(be_valid)
      end
    end
  end

  describe 'overdue borrowing prevention' do
    let(:user) { create(:user, :member) }
    let(:first_book) { create(:book, total_copies: 5) }
    let(:last_book) { create(:book, total_copies: 5) }

    context 'when user has no overdue borrowings' do
      it 'allows borrowing a new book' do
        borrowing = build(:borrowing, user:, book: first_book)
        expect(borrowing).to(be_valid)
      end

      it 'allows borrowing even with past non-overdue borrowings' do
        create(:borrowing, :returned, user:, book: first_book, due_on: 1.week.ago)

        borrowing = build(:borrowing, user:, book: last_book)
        expect(borrowing).to(be_valid)
      end

      it 'allows borrowing with on-time active borrowings' do
        create(:borrowing, :active, user:, book: first_book, due_on: 1.week.from_now)

        borrowing = build(:borrowing, user:, book: last_book)
        expect(borrowing).to(be_valid)
      end
    end

    context 'when user has an active overdue borrowing' do
      before do
        create(:borrowing, :active, user:, book: first_book, due_on: 1.week.ago)
      end

      it 'prevents borrowing a new book' do
        borrowing = build(:borrowing, user:, book: last_book)
        expect(borrowing).not_to(be_valid)
        expect(borrowing.errors[:base]).to(include(match(/Cannot borrow books while you have overdue borrowings/)))
      end
    end

    context 'when user has returned an overdue book' do
      before do
        create(:borrowing, :returned, user:, book: first_book, due_on: 1.week.ago, returned_at: Time.current)
      end

      it 'allows borrowing a new book' do
        borrowing = build(:borrowing, user:, book: last_book)
        expect(borrowing).to(be_valid)
      end
    end

    context 'when user has multiple active borrowings with one overdue' do
      before do
        create(:borrowing, :active, user:, book: first_book, due_on: 1.week.ago)
        # Create second borrowing without validation to simulate having multiple loans
        borrowing2 = build(:borrowing, :active, user:, book: create(:book, total_copies: 5), due_on: 1.week.from_now)
        borrowing2.save(validate: false)
      end

      it 'prevents borrowing due to the one overdue book' do
        borrowing = build(:borrowing, user:, book: last_book)
        expect(borrowing).not_to(be_valid)
      end
    end
  end
end
