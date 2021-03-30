# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_29_002710) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "name"
    t.string "text"
    t.string "country"
    t.string "city"
    t.string "owner_type"
    t.bigint "owner_id"
    t.integer "order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_addresses_on_owner_type_and_owner_id"
  end

  create_table "attached_files", force: :cascade do |t|
    t.string "url", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attached_resource_files", force: :cascade do |t|
    t.bigint "attached_file_id", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "kind"
    t.integer "order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["attached_file_id"], name: "index_attached_resource_files_on_attached_file_id"
    t.index ["owner_type", "owner_id"], name: "index_attached_resource_files_on_owner_type_and_owner_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "url"
    t.hstore "phone"
    t.hstore "email"
    t.string "contact_info"
    t.hstore "social_media"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "url"
    t.hstore "phone"
    t.hstore "email"
    t.string "type"
    t.string "contact_info"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.hstore "social_media", default: {}
  end

  create_table "contact_forms", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.bigint "user_id", null: false
    t.string "user_phone"
    t.string "message"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_contact_forms_on_owner_type_and_owner_id"
    t.index ["user_id"], name: "index_contact_forms_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.bigint "section_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.integer "show_order"
    t.index ["section_id"], name: "index_items_on_section_id"
  end

  create_table "lookup_tables", force: :cascade do |t|
    t.string "category"
    t.integer "code"
    t.string "value"
    t.string "translation_spa"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "related_category"
    t.text "related_category_codes", default: [], array: true
    t.index ["category"], name: "index_lookup_tables_on_category"
  end

  create_table "product_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_product_items_on_item_id"
    t.index ["product_id"], name: "index_product_items_on_product_id"
  end

  create_table "product_subitems", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "subitem_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_product_subitems_on_product_id"
    t.index ["subitem_id"], name: "index_product_subitems_on_subitem_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "short_desc"
    t.string "long_desc"
    t.string "reference"
    t.integer "brand_id"
    t.integer "client_id"
    t.integer "price"
    t.text "work_type", default: [], array: true
    t.text "room_type", default: [], array: true
    t.text "project_type", default: [], array: true
    t.text "tags", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "created_reason"
    t.integer "original_product_id"
    t.integer "user_id"
    t.integer "spec_item_id"
  end

  create_table "project_spec_blocks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "spec_item_type"
    t.bigint "spec_item_id"
    t.bigint "project_spec_id", null: false
    t.integer "order", default: 0, null: false
    t.bigint "section_id"
    t.bigint "item_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "product_image_id"
    t.integer "section_order"
    t.integer "item_order"
    t.integer "product_order"
    t.index ["item_id"], name: "index_project_spec_blocks_on_item_id"
    t.index ["project_spec_id"], name: "index_project_spec_blocks_on_project_spec_id"
    t.index ["section_id"], name: "index_project_spec_blocks_on_section_id"
    t.index ["spec_item_type", "spec_item_id"], name: "index_project_spec_blocks_on_spec_item_type_and_spec_item_id"
  end

  create_table "project_spec_texts", force: :cascade do |t|
    t.string "text", null: false
    t.uuid "project_spec_block_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_spec_block_id"], name: "index_project_spec_texts_on_project_spec_block_id"
  end

  create_table "project_specs", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_project_specs_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.integer "project_type", null: false
    t.integer "work_type", null: false
    t.string "country"
    t.string "city"
    t.string "description"
    t.date "delivery_date"
    t.integer "status", default: 1, null: false
    t.integer "visibility", default: 0, null: false
    t.boolean "soft_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "size"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "eng_name"
    t.integer "show_order"
    t.string "code"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true
    t.datetime "expires"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subitems", force: :cascade do |t|
    t.string "name"
    t.bigint "item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
    t.index ["item_id"], name: "index_subitems_on_item_id"
  end

  create_table "user_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_user_clients_on_client_id"
    t.index ["user_id"], name: "index_user_clients_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "google_token"
    t.string "first_name"
    t.string "last_name"
    t.date "birthday"
    t.string "company"
    t.string "city"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "attached_resource_files", "attached_files"
  add_foreign_key "contact_forms", "users"
  add_foreign_key "items", "sections", on_delete: :cascade
  add_foreign_key "product_items", "items"
  add_foreign_key "product_items", "products"
  add_foreign_key "product_subitems", "products"
  add_foreign_key "product_subitems", "subitems"
  add_foreign_key "project_spec_blocks", "items"
  add_foreign_key "project_spec_blocks", "project_specs"
  add_foreign_key "project_spec_blocks", "sections"
  add_foreign_key "project_spec_texts", "project_spec_blocks"
  add_foreign_key "project_specs", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "subitems", "items", on_delete: :cascade
  add_foreign_key "user_clients", "clients"
  add_foreign_key "user_clients", "users"
end
