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

ActiveRecord::Schema.define(version: 20160911225143) do

  create_table "articles", force: :cascade do |t|
    t.text     "content"
    t.boolean  "published",    default: false
    t.integer  "author_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "published_at"
  end

  add_index "articles", ["author_id"], name: "index_articles_on_author_id"
  add_index "articles", ["published_at"], name: "index_articles_on_published_at"

  create_table "podcasts", force: :cascade do |t|
    t.string   "title"
    t.string   "podcast_file"
    t.integer  "end_time"
    t.integer  "bitrate"
    t.boolean  "published",    default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "series_id"
    t.datetime "published_at"
    t.string   "chunk_id"
  end

  add_index "podcasts", ["published_at"], name: "index_podcasts_on_published_at"
  add_index "podcasts", ["series_id"], name: "index_podcasts_on_series_id"
  add_index "podcasts", ["title", "created_at"], name: "index_podcasts_on_title_and_created_at"
  add_index "podcasts", ["title", "published_at"], name: "index_podcasts_on_title_and_published_at"
  add_index "podcasts", ["title"], name: "index_podcasts_on_title"

  create_table "series", force: :cascade do |t|
    t.string   "title"
    t.boolean  "published",    default: false
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "description"
    t.datetime "published_at"
  end

  add_index "series", ["published_at"], name: "index_series_on_published_at"
  add_index "series", ["user_id"], name: "index_series_on_user_id"

  create_table "timestamps", force: :cascade do |t|
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "podcast_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "article_id"
  end

  add_index "timestamps", ["article_id"], name: "index_timestamps_on_article_id"
  add_index "timestamps", ["podcast_id"], name: "index_timestamps_on_podcast_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
