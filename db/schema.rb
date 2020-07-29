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

ActiveRecord::Schema.define(version: 2020_07_29_182542) do

  create_table "events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "event_id"
    t.string "type"
    t.string "title", null: false
    t.string "url", null: false
    t.string "shortener_url"
    t.text "description"
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.integer "limit_number"
    t.string "address", null: false
    t.string "place", null: false
    t.float "lat"
    t.float "lon"
    t.string "owner_id"
    t.string "owner_nickname"
    t.string "owner_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0, null: false
    t.integer "informed_from", default: 0, null: false
    t.index ["event_id", "type"], name: "index_events_on_event_id_and_type", unique: true
    t.index ["started_at", "ended_at"], name: "index_events_on_started_at_and_ended_at"
    t.index ["title"], name: "index_events_on_title"
  end

  create_table "twitter_bots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "tweet", null: false
    t.string "tweet_id", null: false
    t.string "from_type"
    t.integer "from_id"
    t.datetime "tweet_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_type", "from_id"], name: "index_twitter_bots_on_from_type_and_from_id"
    t.index ["tweet_id"], name: "index_twitter_bots_on_tweet_id"
  end

  create_table "youtube_videos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "video_id", default: "", null: false
    t.integer "youtube_channel_id"
    t.integer "youtube_category_id"
    t.string "title", default: "", null: false
    t.text "description"
    t.string "thumnail_image_url", default: "", null: false
    t.datetime "published_at"
    t.integer "comment_count", default: 0, null: false
    t.integer "dislike_count", default: 0, null: false
    t.integer "like_count", default: 0, null: false
    t.integer "favorite_count", default: 0, null: false
    t.bigint "view_count", default: 0, null: false
    t.boolean "is_related", default: false, null: false
    t.text "tags"
    t.index ["published_at"], name: "index_youtube_videos_on_published_at"
    t.index ["video_id"], name: "index_youtube_videos_on_video_id", unique: true
    t.index ["youtube_channel_id"], name: "index_youtube_videos_on_youtube_channel_id"
  end

end
