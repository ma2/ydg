# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170905123311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hands", force: :cascade do |t|
    t.integer "value"
    t.bigint "janken_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["janken_id"], name: "index_hands_on_janken_id"
    t.index ["user_id"], name: "index_hands_on_user_id"
  end

  create_table "jankens", force: :cascade do |t|
    t.string "jid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "userid"
    t.string "name"
    t.integer "q1", default: 0
    t.integer "q2", default: 0
    t.integer "q3", default: 0
    t.integer "q4", default: 0
    t.integer "q5", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
