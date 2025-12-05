# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table(:users, id: :uuid) do |t|
      t.column(:email_address, :citext, null: false)
      t.string(:password_digest, null: false)
      t.integer(:role, null: false, default: 0)

      t.timestamps
    end

    add_index(:users, :email_address, unique: true)
    add_index(:users, :role)
  end
end
