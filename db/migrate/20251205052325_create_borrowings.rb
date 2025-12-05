# frozen_string_literal: true

class CreateBorrowings < ActiveRecord::Migration[8.1]
  def change
    create_table(:borrowings, id: :uuid) do |t|
      t.references(:user, null: false, foreign_key: true, type: :uuid)
      t.references(:book, null: false, foreign_key: true, type: :uuid)
      t.datetime(:borrowed_at, null: false, default: -> { 'CURRENT_TIMESTAMP' })
      t.date(:due_on, null: false)
      t.datetime(:returned_at)
      t.integer(:status, null: false, default: 0)

      t.timestamps
    end

    add_index(:borrowings, :status)
    add_index(:borrowings, :due_on)
    add_index(:borrowings, :returned_at)

    # Unique constraint: A user cannot have multiple active borrowings for the same book
    add_index(:borrowings, %i[user_id book_id],
              unique: true,
              where: 'returned_at IS NULL',
              name: 'index_borrowings_unique_active_per_user_book')
  end
end
