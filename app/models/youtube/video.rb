# == Schema Information
#
# Table name: youtube_videos
#
#  id                  :integer          not null, primary key
#  video_id            :string(255)      default(""), not null
#  youtube_channel_id  :integer
#  youtube_category_id :integer
#  title               :string(255)      default(""), not null
#  description         :text(65535)
#  thumnail_image_url  :string(255)      default(""), not null
#  published_at        :datetime
#  comment_count       :integer          default(0), not null
#  dislike_count       :integer          default(0), not null
#  like_count          :integer          default(0), not null
#  favorite_count      :integer          default(0), not null
#  view_count          :integer          default(0), not null
#  is_related          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_youtube_videos_on_published_at        (published_at)
#  index_youtube_videos_on_video_id            (video_id) UNIQUE
#  index_youtube_videos_on_youtube_channel_id  (youtube_channel_id)
#

class Youtube::Video < ApplicationRecord
  serialize :tags, JSON

  def embed_url
    return "https://www.youtube.com/embed/" + self.video_id + "?autoplay=1"
  end

  def self.import_video!(youtube_video:, is_related: false)
    videos = []
    youtube_video.items.each do |item|
      video = Youtube::Video.new(
        video_id: item.id,
        title: Sanitizer.basic_sanitize(item.snippet.title),
        description: Sanitizer.basic_sanitize(item.snippet.description),
        published_at: item.snippet.published_at,
        thumnail_image_url: item.snippet.thumbnails.default.url,
        comment_count: item.statistics.try(:comment_count).to_i,
        dislike_count: item.statistics.try(:dislike_count).to_i,
        like_count: item.statistics.try(:like_count).to_i,
        favorite_count: item.statistics.try(:favorite_count).to_i,
        view_count: item.statistics.try(:view_count).to_i,
        is_related: is_related,
        tags: item.snippet.tags
      )
      videos << video
    end
    updates = [:published_at]
    Youtube::Video.import(videos, on_duplicate_key_update: updates)
  end
end
