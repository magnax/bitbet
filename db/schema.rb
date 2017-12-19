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

ActiveRecord::Schema.define(version: 20131122224905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.integer  "user_id"
    t.string   "nr"
    t.string   "account_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bets", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "text"
    t.integer  "category_id"
    t.date     "event_at"
    t.date     "deadline"
    t.datetime "closed_at"
    t.string   "status"
    t.boolean  "positive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "banned",       default: false
    t.datetime "published_at"
  end

  create_table "bids", force: true do |t|
    t.integer  "user_id"
    t.integer  "bet_id"
    t.integer  "amount"
    t.boolean  "positive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fees", force: true do |t|
    t.integer  "amount",     limit: 8
    t.integer  "bet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notes"
  end

  create_table "operations", force: true do |t|
    t.integer  "user_id"
    t.integer  "amount"
    t.integer  "account_id"
    t.integer  "bet_id"
    t.string   "operation_type"
    t.string   "txid"
    t.integer  "time"
    t.integer  "timereceived"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ref_id"
  end

end
