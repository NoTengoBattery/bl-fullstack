# frozen_string_literal: true

# Serializer for Book model
# Provides different views for list vs detail pages
class BookBlueprint < ApplicationBlueprint
  fields :title, :author, :genre, :isbn, :total_copies

  datetime_field :created_at
  datetime_field :updated_at

  # Dynamic field: availability status
  field :available do |book, _options|
    book.available?
  end

  # Dynamic field: number of available copies
  field :available_copies do |book, _options|
    book.available_copies
  end

  # Card view for list pages (minimal data for cards)
  view :card do
    excludes :created_at, :updated_at, :isbn
  end

  # Extended view with borrowing information (for librarian dashboard)
  view :extended do
    field :active_borrowings_count do |book, _options|
      book.borrowings.active.count
    end
  end

  # View for including soft-delete status (librarian only)
  view :with_status do
    field :discarded do |book, _options|
      book.discarded?
    end

    datetime_field :discarded_at
  end
end
