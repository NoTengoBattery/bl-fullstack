# frozen_string_literal: true

# Migration to create the visits table.
# Tracks user logins with IP address.
class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table(:visits, id: :uuid) do |t|
      t.references(:user, null: false, foreign_key: true, type: :uuid)
      t.string(:ip_address, null: false)

      t.timestamps
    end
  end
end
