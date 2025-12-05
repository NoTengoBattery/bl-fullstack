# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(BookPolicy) do
  subject(:policy) { described_class.new(user, book) }

  let(:book) { create(:book) }

  describe 'for a member' do
    let(:user) { create(:user, :member) }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.to(permit_action(:show)) }
    it { is_expected.to(permit_action(:search)) }
    it { is_expected.not_to(permit_action(:create)) }
    it { is_expected.not_to(permit_action(:new)) }
    it { is_expected.not_to(permit_action(:update)) }
    it { is_expected.not_to(permit_action(:edit)) }
    it { is_expected.not_to(permit_action(:destroy)) }
  end

  describe 'for a librarian' do
    let(:user) { create(:user, :librarian) }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.to(permit_action(:show)) }
    it { is_expected.to(permit_action(:search)) }
    it { is_expected.to(permit_action(:create)) }
    it { is_expected.to(permit_action(:new)) }
    it { is_expected.to(permit_action(:update)) }
    it { is_expected.to(permit_action(:edit)) }
    it { is_expected.to(permit_action(:destroy)) }
  end

  describe 'for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.to(permit_action(:index)) }
    it { is_expected.to(permit_action(:show)) }
    it { is_expected.to(permit_action(:search)) }
    it { is_expected.not_to(permit_action(:create)) }
    it { is_expected.not_to(permit_action(:new)) }
    it { is_expected.not_to(permit_action(:update)) }
    it { is_expected.not_to(permit_action(:edit)) }
    it { is_expected.not_to(permit_action(:destroy)) }
  end

  describe 'scope' do
    let(:user) { create(:user, :member) }
    let!(:kept_book) { create(:book, :kept) }
    let!(:discarded_book) { create(:book, :discarded) }

    it 'returns only kept (non-discarded) books for regular users' do
      scope = described_class::Scope.new(user, Book).resolve
      expect(scope).to(include(kept_book))
      expect(scope).not_to(include(discarded_book))
    end

    context 'when user is librarian' do
      let(:user) { create(:user, :librarian) }

      it 'returns all books including discarded' do
        scope = described_class::Scope.new(user, Book).resolve
        expect(scope).to(include(kept_book))
        expect(scope).to(include(discarded_book))
      end
    end
  end
end
