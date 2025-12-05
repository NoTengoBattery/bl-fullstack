# frozen_string_literal: true

require_relative '../seed_helper'

seed_model(model: 'Borrowing', times: 200) do |borrowing|
  borrowing.user = User.member.random_sample
  borrowing.book = Book.kept.random_sample
end
