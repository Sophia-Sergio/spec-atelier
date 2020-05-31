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

ActiveRecord::Schema.define(version: 2020_05_29_064706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "brand_contact_forms", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "user_id", null: false
    t.string "user_phone"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand_id"], name: "index_brand_contact_forms_on_brand_id"
    t.index ["user_id"], name: "index_brand_contact_forms_on_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "description"
    t.string "address"
    t.string "country"
    t.hstore "phone", default: {}, null: false
    t.string "web"
    t.hstore "email", default: {}, null: false
    t.hstore "social_media", default: {}, null: false
  end

  create_table "files", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.integer "order", default: 0
    t.string "url", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_files_on_owner_type_and_owner_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.bigint "section_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["section_id"], name: "index_items_on_section_id"
  end

  create_table "lookup_tables", force: :cascade do |t|
    t.string "category"
    t.integer "code"
    t.string "value"
    t.string "translation_spa"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_lookup_tables_on_category"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "short_desc"
    t.string "long_desc"
    t.string "reference"
    t.bigint "brand_id", null: false
    t.integer "price"
    t.text "work_type", default: [], array: true
    t.text "room_type", default: [], array: true
    t.text "project_type", default: [], array: true
    t.text "tags", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "subitem_id"
    t.bigint "item_id", default: 1, null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["item_id"], name: "index_products_on_item_id"
  end

  create_table "project_spec_items", force: :cascade do |t|
    t.string "spec_item_type"
    t.integer "spec_item_id"
    t.bigint "project_spec_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "section_id", null: false
    t.bigint "item_id", null: false
    t.index ["item_id"], name: "index_project_spec_items_on_item_id"
    t.index ["project_spec_id"], name: "index_project_spec_items_on_project_spec_id"
    t.index ["section_id"], name: "index_project_spec_items_on_section_id"
    t.index ["user_id"], name: "index_project_spec_items_on_user_id"
  end

  create_table "project_spec_texts", force: :cascade do |t|
    t.string "text", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.date "delivery_date"
    t.integer "status", default: 1, null: false
    t.integer "visibility", default: 0, null: false
    t.boolean "soft_deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "spec_texts", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_spec_texts_on_project_id"
  end

  create_table "subitems", force: :cascade do |t|
    t.string "name"
    t.bigint "item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_subitems_on_item_id"
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
    t.string "office"
    t.string "profile_image"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "brand_contact_forms", "brands"
  add_foreign_key "brand_contact_forms", "users"
  add_foreign_key "items", "sections", on_delete: :cascade
  add_foreign_key "products", "brands", on_delete: :cascade
  add_foreign_key "products", "items"
  add_foreign_key "project_spec_items", "items"
  add_foreign_key "project_spec_items", "project_specs"
  add_foreign_key "project_spec_items", "sections"
  add_foreign_key "project_spec_items", "users"
  add_foreign_key "project_specs", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "spec_texts", "projects"
  add_foreign_key "subitems", "items", on_delete: :cascade
end
