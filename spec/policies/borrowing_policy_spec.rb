# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(BorrowingPolicy) do
  subject(:policy) { described_class.new(user, borrowing) }

  let(:book) { create(:book) }
  let(:borrowing_owner) { create(:user, :member) }
  let(:borrowing) { create(:borrowing, user: borrowing_owner, book:) }

  describe 'for a member (owner of the borrowing)' do
    let(:user) { borrowing_owner }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.to(permit_action(:show)) }
    it { is_expected.to(permit_action(:create)) }
    it { is_expected.not_to(permit_action(:update)) }
    it { is_expected.not_to(permit_action(:destroy)) }
  end

  describe 'for a member (not owner of the borrowing)' do
    let(:user) { create(:user, :member) }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.not_to(permit_action(:show)) }
    it { is_expected.to(permit_action(:create)) }
    it { is_expected.not_to(permit_action(:update)) }
    it { is_expected.not_to(permit_action(:destroy)) }
  end

  describe 'for a librarian' do
    let(:user) { create(:user, :librarian) }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.to(permit_action(:show)) }
    it { is_expected.to(permit_action(:create)) }
    it { is_expected.to(permit_action(:update)) }
    it { is_expected.not_to(permit_action(:destroy)) }
  end

  describe 'for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.not_to(permit_action(:index)) }
    it { is_expected.not_to(permit_action(:show)) }
    it { is_expected.not_to(permit_action(:create)) }
    it { is_expected.not_to(permit_action(:update)) }
    it { is_expected.not_to(permit_action(:destroy)) }
  end

  describe 'scope' do
    let(:user) { create(:user, :member) }
    let!(:user_borrowing) { create(:borrowing, user:, book:) }
    let!(:other_borrowing) { create(:borrowing, user: create(:user), book: create(:book)) }

    it 'returns only the user\'s borrowings for members' do
      scope = described_class::Scope.new(user, Borrowing).resolve
      expect(scope).to(include(user_borrowing))
      expect(scope).not_to(include(other_borrowing))
    end

    context 'when user is librarian' do
      let(:user) { create(:user, :librarian) }

      it 'returns all borrowings' do
        scope = described_class::Scope.new(user, Borrowing).resolve
        expect(scope).to(include(user_borrowing))
        expect(scope).to(include(other_borrowing))
      end
    end
  end
end
