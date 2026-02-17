# frozen_string_literal: true

# Migration to create the users table.
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table(:users, id: :uuid) do |t|
      t.column(:email_address, :citext, null: false)
      t.string(:password_digest, null: false)

      t.timestamps
    end

    add_index(:users, :email_address, unique: true)
  end
end
