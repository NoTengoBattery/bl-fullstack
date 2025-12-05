# frozen_string_literal: true

require_relative '../seed_helper'

seed_model(model: 'User', times: 20)

# Guarantee at least one librarian user
if User.librarian.none?
  User.member.random_sample.delete
  seed_model(model: 'User', factory_kw: { role: :librarian }, times: 20)
end
