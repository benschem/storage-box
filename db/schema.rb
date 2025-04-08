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

ActiveRecord::Schema[7.1].define(version: 2025_04_08_062331) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boxes", force: :cascade do |t|
    t.integer "number"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number", "room_id"], name: "index_boxes_on_number_and_room_id", unique: true
    t.index ["room_id"], name: "index_boxes_on_room_id"
  end

  create_table "boxes_tags", id: false, force: :cascade do |t|
    t.bigint "box_id", null: false
    t.bigint "tag_id", null: false
    t.index ["box_id", "tag_id"], name: "index_boxes_tags_on_box_id_and_tag_id", unique: true
    t.index ["tag_id", "box_id"], name: "index_boxes_tags_on_tag_id_and_box_id", unique: true
  end

  create_table "households", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "households_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "household_id", null: false
    t.index ["household_id", "user_id"], name: "index_households_users_on_household_id_and_user_id", unique: true
    t.index ["user_id", "household_id"], name: "index_households_users_on_user_id_and_household_id", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.bigint "box_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["box_id"], name: "index_items_on_box_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.bigint "household_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_rooms_on_household_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "boxes", "rooms"
  add_foreign_key "items", "boxes"
  add_foreign_key "rooms", "households"
end
