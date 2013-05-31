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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130531063539) do

  create_table "event_properties", :force => true do |t|
    t.integer "event_id"
    t.string  "name"
    t.string  "value"
  end

  create_table "events", :force => true do |t|
    t.integer "user_id"
    t.string  "event"
    t.date    "date"
  end

  create_table "friendrelationships", :force => true do |t|
    t.string   "user_id"
    t.string   "friend_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "quests", :force => true do |t|
    t.string "name"
    t.string "quest_ordering"
    t.string "reward"
  end

  create_table "send_messages", :force => true do |t|
    t.string   "sender_id"
    t.string   "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_applications", :id => false, :force => true do |t|
    t.string "user_id",        :null => false
    t.string "application_id", :null => false
  end

  create_table "user_stocks", :force => true do |t|
    t.string  "user_id"
    t.string  "stock"
    t.integer "shares"
    t.string  "type_stock"
    t.integer "stock_id"
  end

  create_table "users", :force => true do |t|
    t.text     "facebook_token"
    t.string   "stockyard_name"
    t.date     "date_token_updated"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "fb_id"
    t.text     "email"
  end

end
