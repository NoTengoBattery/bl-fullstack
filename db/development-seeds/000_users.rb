# frozen_string_literal: true

require_relative '../seed_helper'

seed_model(model: 'User', times: 1, factory_opts: [:librarian]) do |librarian|
  librarian.email_address = 'librarian@library.com'
  librarian.password = librarian.password_confirmation = 'password'
end

seed_model(model: 'User', times: 2, factory_opts: [:member]) do |member|
  member.email_address = 'member@library.com'
  member.password = member.password_confirmation = 'password'
end

seed_model(model: 'User', times: 20)

# Guarantee at least one librarian user
if User.librarian.none?
  User.member.random_sample.delete
  seed_model(model: 'User', factory_kw: { role: :librarian }, times: 20)
end
