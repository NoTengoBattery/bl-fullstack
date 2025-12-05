# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(User) do
  describe 'validations' do
    subject(:user) { build(:user) }

    it { is_expected.to(validate_presence_of(:email_address)) }
    it { is_expected.to(validate_uniqueness_of(:email_address).case_insensitive) }
    it { is_expected.to(validate_presence_of(:password).on(:create)) }
    it { is_expected.to(have_secure_password) }
  end

  describe 'associations' do
    it { is_expected.to(have_many(:borrowings).dependent(:restrict_with_error)) }
  end

  describe 'enums' do
    it { is_expected.to(define_enum_for(:role).with_values(member: 0, librarian: 1)) }
  end

  describe 'default values' do
    it 'defaults role to member' do
      user = described_class.new
      expect(user.role).to(eq('member'))
    end
  end

  describe '#member?' do
    it 'returns true for member role' do
      user = build(:user, role: :member)
      expect(user).to(be_member)
    end

    it 'returns false for librarian role' do
      user = build(:user, role: :librarian)
      expect(user).not_to(be_member)
    end
  end

  describe '#librarian?' do
    it 'returns true for librarian role' do
      user = build(:user, role: :librarian)
      expect(user).to(be_librarian)
    end

    it 'returns false for member role' do
      user = build(:user, role: :member)
      expect(user).not_to(be_librarian)
    end
  end
end
