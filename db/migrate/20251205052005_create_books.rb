# frozen_string_literal: true

# Migration to create the books table with search indexes.
class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table(:books, id: :uuid) do |t|
      t.string(:title, null: false)
      t.string(:author, null: false)
      t.column(:genre, :citext)
      t.column(:isbn, :citext)
      t.integer(:total_copies, null: false, default: 0)
      t.integer(:lock_version, null: false, default: 0)
      t.datetime(:discarded_at)

      t.timestamps
    end

    add_index(:books, :genre)
    add_index(:books, :isbn, unique: true)
    add_index(:books, :discarded_at)
    add_index(:books, %i[title author genre],
              name: 'index_books_on_search_fields',
              using: :gin,
              opclass: { title: :gin_trgm_ops, author: :gin_trgm_ops, genre: :gin_trgm_ops })

    # Add check constraint for non-negative total_copies
    add_check_constraint(:books, 'total_copies >= 0', name: 'check_books_total_copies_non_negative')
  end
end
