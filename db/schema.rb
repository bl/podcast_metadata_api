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

ActiveRecord::Schema.define(version: 20161025221025) do

  create_table "articles", force: :cascade do |t|
    t.text     "content"
    t.boolean  "published",    default: false
    t.integer  "author_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "published_at"
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["published_at"], name: "index_articles_on_published_at"
  end

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
    t.index ["published_at"], name: "index_podcasts_on_published_at"
    t.index ["series_id"], name: "index_podcasts_on_series_id"
    t.index ["title", "created_at"], name: "index_podcasts_on_title_and_created_at"
    t.index ["title", "published_at"], name: "index_podcasts_on_title_and_published_at"
    t.index ["title"], name: "index_podcasts_on_title"
  end

  create_table "series", force: :cascade do |t|
    t.string   "title"
    t.boolean  "published",    default: false
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "description"
    t.datetime "published_at"
    t.index ["published_at"], name: "index_series_on_published_at"
    t.index ["user_id"], name: "index_series_on_user_id"
  end

  create_table "timestamps", force: :cascade do |t|
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "podcast_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "article_id"
    t.index ["article_id"], name: "index_timestamps_on_article_id"
    t.index ["podcast_id"], name: "index_timestamps_on_podcast_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.string   "chunk_id",     null: false
    t.integer  "total_size"
    t.string   "ext"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "user_id",      null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "chunk_size"
    t.index ["chunk_id"], name: "index_uploads_on_chunk_id", unique: true
    t.index ["subject_type", "subject_id"], name: "index_uploads_on_subject_type_and_subject_id"
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

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
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
