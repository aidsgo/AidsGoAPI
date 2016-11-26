# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161125100329) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "elders", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.date     "birthday"
    t.string   "sex"
    t.string   "community"
    t.string   "image"
    t.jsonb    "contact"
    t.integer  "help_count"
    t.jsonb    "emergency_call"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "serial_number"
    t.string   "address"
  end

  create_table "emergencies", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "elder_id",       null: false
    t.jsonb    "elder_location"
    t.uuid     "resolved"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.jsonb    "accept"
    t.jsonb    "reject"
  end

  create_table "volunteers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.date     "birthday"
    t.string   "sex"
    t.string   "community"
    t.string   "image"
    t.jsonb    "contact"
    t.integer  "help_count"
    t.jsonb    "emergency_call"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "pwd"
    t.string   "public_key"
    t.string   "phone"
  end

end
