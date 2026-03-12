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

ActiveRecord::Schema[8.1].define(version: 2026_03_12_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "patch_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["patch_id"], name: "index_chats_on_patch_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "game_id", null: false
    t.datetime "start_date"
    t.text "summary"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_events_on_game_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["game_id"], name: "index_favourites_on_game_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "cover_image"
    t.datetime "created_at", null: false
    t.boolean "free_to_play", default: false, null: false
    t.string "genre"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_games_on_lower_name", unique: true
    t.index ["slug"], name: "index_games_on_slug", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "patch_summaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "patch_id", null: false
    t.text "summary"
    t.string "summary_type"
    t.datetime "updated_at", null: false
    t.index ["patch_id"], name: "index_patch_summaries_on_patch_id"
  end

  create_table "patches", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.datetime "published_at"
    t.string "source_url"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_patches_on_game_id"
    t.index ["published_at"], name: "index_patches_on_published_at"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_reminders_on_event_id"
    t.index ["user_id"], name: "index_reminders_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "follower_count"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "patches"
  add_foreign_key "chats", "users"
  add_foreign_key "events", "games"
  add_foreign_key "favourites", "games"
  add_foreign_key "favourites", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "patch_summaries", "patches"
  add_foreign_key "patches", "games"
  add_foreign_key "reminders", "events"
  add_foreign_key "reminders", "users"
end
