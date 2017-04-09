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

ActiveRecord::Schema.define(version: 20170409002943) do

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "event_id",                           null: false
    t.string   "type",                               null: false
    t.string   "keyword",                            null: false
    t.string   "title",                              null: false
    t.string   "url",                                null: false
    t.string   "description",                        null: false
    t.datetime "started_at",                         null: false
    t.datetime "ended_at",                           null: false
    t.integer  "limit",                  default: 0, null: false
    t.string   "address",                            null: false
    t.string   "place",                              null: false
    t.float    "lat",         limit: 24
    t.float    "lon",         limit: 24
    t.string   "owner_id",                           null: false
    t.string   "owner_name"
    t.index ["event_id", "type"], name: "index_events_on_event_id_and_type", unique: true, using: :btree
    t.index ["keyword"], name: "index_events_on_keyword", using: :btree
    t.index ["started_at", "ended_at"], name: "index_events_on_started_at_and_ended_at", using: :btree
  end

  create_table "youtube_video_relateds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "youtube_video_id",    null: false
    t.integer "to_youtube_video_id", null: false
    t.index ["to_youtube_video_id"], name: "index_youtube_video_relateds_on_to_youtube_video_id", using: :btree
    t.index ["youtube_video_id"], name: "index_youtube_video_relateds_on_youtube_video_id", using: :btree
  end

  create_table "youtube_video_tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "youtube_video_id", null: false
    t.string  "tag",              null: false
    t.index ["tag"], name: "index_youtube_video_tags_on_tag", using: :btree
    t.index ["youtube_video_id", "tag"], name: "index_youtube_video_tags_on_youtube_video_id_and_tag", unique: true, using: :btree
  end

  create_table "youtube_videos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "video_id",                          default: "", null: false
    t.integer  "youtube_channel_id"
    t.integer  "youtube_category_id"
    t.string   "title",                             default: "", null: false
    t.text     "description",         limit: 65535
    t.string   "thumnail_image_url",                default: "", null: false
    t.datetime "published_at"
    t.integer  "comment_count",                     default: 0,  null: false
    t.integer  "dislike_count",                     default: 0,  null: false
    t.integer  "like_count",                        default: 0,  null: false
    t.integer  "favorite_count",                    default: 0,  null: false
    t.bigint   "view_count",                        default: 0,  null: false
    t.index ["published_at"], name: "index_youtube_videos_on_published_at", using: :btree
    t.index ["video_id"], name: "index_youtube_videos_on_video_id", unique: true, using: :btree
    t.index ["youtube_channel_id"], name: "index_youtube_videos_on_youtube_channel_id", using: :btree
  end

end