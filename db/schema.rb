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

ActiveRecord::Schema[7.2].define(version: 2026_01_07_111411) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.integer "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", default: "local", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    t.index ["service_name"], name: "index_active_storage_blobs_on_service_name"
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    t.index ["blob_id"], name: "index_active_storage_variant_records_on_blob_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "cricket_match_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "team_size", null: false
    t.string "category", null: false
    t.string "sub_category"
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tournaments_count", default: 0, null: false
    t.index ["active"], name: "index_cricket_match_types_on_active"
    t.index ["category"], name: "index_cricket_match_types_on_category"
    t.index ["slug"], name: "index_cricket_match_types_on_slug", unique: true
    t.index ["team_size"], name: "index_cricket_match_types_on_team_size"
    t.index ["tournaments_count"], name: "index_cricket_match_types_on_tournaments_count"
  end

  create_table "sports", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "icon"
    t.integer "display_order", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tournaments_count", default: 0, null: false
    t.index ["active"], name: "index_sports_on_active"
    t.index ["display_order"], name: "index_sports_on_display_order"
    t.index ["slug"], name: "index_sports_on_slug", unique: true
    t.index ["tournaments_count"], name: "index_sports_on_tournaments_count"
  end

  create_table "team_members", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.string "role", default: "member"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_team_members_on_is_active"
    t.index ["team_id", "user_id"], name: "index_team_members_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "logo"
    t.bigint "sport_id", null: false
    t.bigint "captain_id", null: false
    t.integer "member_count", default: 0
    t.boolean "is_active", default: true
    t.boolean "is_default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["captain_id"], name: "index_teams_on_captain_id"
    t.index ["is_active"], name: "index_teams_on_is_active"
    t.index ["slug"], name: "index_teams_on_slug", unique: true
    t.index ["sport_id"], name: "index_teams_on_sport_id"
  end

  create_table "tournament_likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_tournament_likes_on_tournament_id"
    t.index ["user_id", "tournament_id"], name: "index_tournament_likes_on_user_id_and_tournament_id", unique: true
    t.index ["user_id"], name: "index_tournament_likes_on_user_id"
  end

  create_table "tournament_participants", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.bigint "user_id", null: false
    t.bigint "team_id"
    t.string "status", default: "pending"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_tournament_participants_on_status"
    t.index ["team_id"], name: "index_tournament_participants_on_team_id"
    t.index ["tournament_id", "user_id"], name: "index_tournament_participants_on_tournament_id_and_user_id", unique: true
    t.index ["tournament_id"], name: "index_tournament_participants_on_tournament_id"
    t.index ["user_id"], name: "index_tournament_participants_on_user_id"
  end

  create_table "tournament_teams", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_tournament_teams_on_team_id"
    t.index ["tournament_id", "team_id"], name: "index_tournament_teams_on_tournament_id_and_team_id", unique: true
    t.index ["tournament_id"], name: "index_tournament_teams_on_tournament_id"
  end

  create_table "tournament_themes", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "preview_image_url"
    t.string "color_scheme"
    t.integer "display_order", default: 0
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "template_html"
    t.index ["display_order"], name: "index_tournament_themes_on_display_order"
    t.index ["is_active"], name: "index_tournament_themes_on_is_active"
    t.index ["slug"], name: "index_tournament_themes_on_slug", unique: true
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "description"
    t.bigint "sport_id", null: false
    t.bigint "cricket_match_type_id"
    t.bigint "venue_id"
    t.bigint "created_by_id", null: false
    t.bigint "tournament_theme_id"
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "max_players_per_team"
    t.integer "min_players_per_team"
    t.decimal "entry_fee"
    t.string "tournament_status", default: "draft"
    t.string "pincode", null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.integer "view_count", default: 0
    t.integer "join_count", default: 0
    t.boolean "is_featured", default: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "first_prize", precision: 10, scale: 2
    t.decimal "second_prize", precision: 10, scale: 2
    t.decimal "third_prize", precision: 10, scale: 2
    t.text "prizes_json", comment: "JSON field for additional prize levels"
    t.text "contact_phones", comment: "JSON array of contact phone numbers"
    t.text "teams_text", comment: "Text field for team names (one per line)"
    t.string "venue_name"
    t.text "venue_address"
    t.decimal "venue_latitude", precision: 10, scale: 7
    t.decimal "venue_longitude", precision: 10, scale: 7
    t.string "venue_google_maps_link"
    t.string "organized_by", comment: "Organizer name (string field, not user association)"
    t.integer "likes_count", default: 0, null: false
    t.index ["created_by_id"], name: "index_tournaments_on_created_by_id"
    t.index ["cricket_match_type_id"], name: "index_tournaments_on_cricket_match_type_id"
    t.index ["is_active"], name: "index_tournaments_on_is_active"
    t.index ["is_featured"], name: "index_tournaments_on_is_featured"
    t.index ["latitude", "longitude"], name: "index_tournaments_on_latitude_and_longitude"
    t.index ["pincode"], name: "index_tournaments_on_pincode"
    t.index ["slug"], name: "index_tournaments_on_slug", unique: true
    t.index ["sport_id", "pincode", "tournament_status", "start_time"], name: "index_tournaments_on_discovery"
    t.index ["sport_id", "tournament_status"], name: "index_tournaments_on_sport_status"
    t.index ["sport_id"], name: "index_tournaments_on_sport_id"
    t.index ["start_time"], name: "index_tournaments_on_start_time"
    t.index ["tournament_status", "is_active", "start_time"], name: "index_tournaments_on_status_active_start_time"
    t.index ["tournament_status"], name: "index_tournaments_on_tournament_status"
    t.index ["tournament_theme_id"], name: "index_tournaments_on_tournament_theme_id"
    t.index ["venue_id"], name: "index_tournaments_on_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "name"
    t.string "encrypted_password", default: "", null: false
    t.string "provider"
    t.string "uid"
    t.string "avatar_url"
    t.string "otp_secret"
    t.datetime "otp_sent_at"
    t.boolean "phone_verified", default: false
    t.string "pincode"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "address"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["latitude", "longitude"], name: "index_users_on_latitude_and_longitude"
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["pincode"], name: "index_users_on_pincode"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "address", null: false
    t.string "pincode", null: false
    t.string "city"
    t.string "state"
    t.string "country", default: "India"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "google_maps_link"
    t.string "contact_phone"
    t.string "contact_email"
    t.decimal "hourly_rate"
    t.boolean "is_verified", default: false
    t.boolean "is_active", default: true
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tournaments_count", default: 0, null: false
    t.index ["created_by_id"], name: "index_venues_on_created_by_id"
    t.index ["is_active"], name: "index_venues_on_is_active"
    t.index ["is_verified"], name: "index_venues_on_is_verified"
    t.index ["latitude", "longitude"], name: "index_venues_on_latitude_and_longitude"
    t.index ["pincode"], name: "index_venues_on_pincode"
    t.index ["tournaments_count"], name: "index_venues_on_tournaments_count"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "teams", "sports"
  add_foreign_key "teams", "users", column: "captain_id"
  add_foreign_key "tournament_likes", "tournaments"
  add_foreign_key "tournament_likes", "users"
  add_foreign_key "tournament_participants", "teams"
  add_foreign_key "tournament_participants", "tournaments"
  add_foreign_key "tournament_participants", "users"
  add_foreign_key "tournament_teams", "teams"
  add_foreign_key "tournament_teams", "tournaments"
  add_foreign_key "tournaments", "cricket_match_types"
  add_foreign_key "tournaments", "sports"
  add_foreign_key "tournaments", "tournament_themes"
  add_foreign_key "tournaments", "users", column: "created_by_id"
  add_foreign_key "tournaments", "venues"
  add_foreign_key "venues", "users", column: "created_by_id"
end
