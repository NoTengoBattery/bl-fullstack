# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_05_052325) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "unaccent"

  create_table "books", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.citext "genre"
    t.citext "isbn"
    t.integer "lock_version", default: 0, null: false
    t.string "title", null: false
    t.integer "total_copies", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_books_on_discarded_at"
    t.index ["genre"], name: "index_books_on_genre"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.index ["title", "author", "genre"], name: "index_books_on_search_fields", opclass: :gin_trgm_ops, using: :gin
    t.check_constraint "total_copies >= 0", name: "check_books_total_copies_non_negative"
  end

  create_table "borrowings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "book_id", null: false
    t.datetime "borrowed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.date "due_on", null: false
    t.datetime "returned_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["book_id"], name: "index_borrowings_on_book_id"
    t.index ["due_on"], name: "index_borrowings_on_due_on"
    t.index ["returned_at"], name: "index_borrowings_on_returned_at"
    t.index ["status"], name: "index_borrowings_on_status"
    t.index ["user_id", "book_id"], name: "index_borrowings_unique_active_per_user_book", unique: true, where: "(returned_at IS NULL)"
    t.index ["user_id"], name: "index_borrowings_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "borrowings", "books"
  add_foreign_key "borrowings", "users"
end
