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

ActiveRecord::Schema[8.1].define(version: 2026_04_09_101001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.datetime "created_at", null: false
    t.bigint "item_id", null: false
    t.bigint "seller_id", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_conversations_on_buyer_id"
    t.index ["item_id", "buyer_id", "seller_id"], name: "index_conversations_on_item_buyer_seller", unique: true
    t.index ["item_id"], name: "index_conversations_on_item_id"
    t.index ["seller_id"], name: "index_conversations_on_seller_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "category"
    t.string "college"
    t.datetime "created_at", null: false
    t.text "description"
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "reserved_at"
    t.string "status", default: "available", null: false
    t.integer "stock_quantity", default: 1, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "visibility_college"
    t.string "visibility_scope", default: "campus", null: false
    t.index ["category"], name: "index_items_on_category"
    t.index ["description"], name: "index_items_on_description", opclass: :gin_trgm_ops, using: :gin
    t.index ["reserved_at"], name: "index_items_on_reserved_at"
    t.index ["status"], name: "index_items_on_status"
    t.index ["title"], name: "index_items_on_title", opclass: :gin_trgm_ops, using: :gin
    t.index ["user_id"], name: "index_items_on_user_id"
    t.index ["visibility_college"], name: "index_items_on_visibility_college"
    t.index ["visibility_scope"], name: "index_items_on_visibility_scope"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "college"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "user_name"
    t.index ["college"], name: "index_users_on_college"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "items"
  add_foreign_key "conversations", "users", column: "buyer_id"
  add_foreign_key "conversations", "users", column: "seller_id"
  add_foreign_key "items", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
end
