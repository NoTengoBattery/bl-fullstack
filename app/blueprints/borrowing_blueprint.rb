# frozen_string_literal: true

# Serializer for Borrowing model
# Handles the relationship between users and books for loan tracking
class BorrowingBlueprint < ApplicationBlueprint
  fields :status

  datetime_field :borrowed_at
  date_field :due_on
  datetime_field :returned_at
  datetime_field :created_at
  datetime_field :updated_at

  # Dynamic field: overdue status
  field :overdue do |borrowing, _options|
    borrowing.active? && borrowing.due_on < Date.current
  end

  # Dynamic field: days until due (negative if overdue)
  field :days_until_due do |borrowing, _options|
    (borrowing.due_on - Date.current).to_i
  end

  # Default view includes associated book (minimal)
  association :book, blueprint: BookBlueprint, view: :card

  # Extended view includes user information (for librarian)
  view :extended do
    association :user, blueprint: UserBlueprint, view: :minimal
  end

  # Minimal view for embedding in other resources
  view :minimal do
    excludes :created_at, :updated_at
  end

  # View for member's own borrowings
  view :member do
    association :book, blueprint: BookBlueprint
  end

  # View for librarian dashboard (includes user info)
  view :librarian do
    association :book, blueprint: BookBlueprint, view: :card
    association :user, blueprint: UserBlueprint, view: :minimal
  end
end
