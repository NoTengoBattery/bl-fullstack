# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Visit) do
  describe 'validations' do
    it { is_expected.to(validate_presence_of(:ip_address)) }
  end

  describe 'associations' do
    it { is_expected.to(belong_to(:user)) }
  end
end
