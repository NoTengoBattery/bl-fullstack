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
    it { is_expected.to(have_many(:visits).dependent(:delete_all)) }
  end
end
