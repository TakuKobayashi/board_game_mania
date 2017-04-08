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
#  comment_count       :integer          default("0"), not null
#  dislike_count       :integer          default("0"), not null
#  like_count          :integer          default("0"), not null
#  favorite_count      :integer          default("0"), not null
#  view_count          :integer          default("0"), not null
#
# Indexes
#
#  index_youtube_videos_on_published_at        (published_at)
#  index_youtube_videos_on_video_id            (video_id) UNIQUE
#  index_youtube_videos_on_youtube_channel_id  (youtube_channel_id)
#

class Youtube::Video < ApplicationRecord
    def self.import_video!(youtube_video)
    videos = []
    id_and_tags = {}
    youtube_video.items.each do |item|
      video = Youtube::Video.new(
        video_id: item.id,
        title: Youtube::Video.basic_sanitize(item.snippet.title),
        description: Youtube::Video.basic_sanitize(item.snippet.description),
        published_at: item.snippet.published_at,
        thumnail_image_url: item.snippet.thumbnails.default.url,
        comment_count: item.statistics.try(:comment_count).to_i,
        dislike_count: item.statistics.try(:dislike_count).to_i,
        like_count: item.statistics.try(:like_count).to_i,
        favorite_count: item.statistics.try(:favorite_count).to_i,
        view_count: item.statistics.try(:view_count).to_i
      )
      id_and_tags[item.id] = item.snippet.tags
      videos << video
    end
    updates = [:published_at]
    Youtube::Video.import(videos, on_duplicate_key_update: updates)
    Youtube::Video.import_tags(id_and_tags)
  end

  def self.import_tags(video_id_and_tags)
    video_ids = Youtube::Video.where(video_id: video_id_and_tags.keys).pluck(:id, :video_id)
    tags = video_ids.map do |id, video_id|
      if video_id_and_tags[video_id].blank?
        nil
      else
        results = []
        video_id_and_tags[video_id].each do |tag|
          sanitized = Youtube::Video.basic_sanitize(tag)
          next if sanitized.blank?
          sanitize_split_tags = [sanitized]
          if sanitized.length > 255
            sanitize_split_tags = sanitized.split(" ")
          end
          results += sanitize_split_tags.map do |t|
            Youtube::VideoTag.new(youtube_video_id: id, tag: t)
          end
        end
        results
      end
    end.flatten.compact
    Youtube::VideoTag.import(tags, on_duplicate_key_update: [:youtube_video_id, :tag])
  end

  def import_related_video!(youtube_video)
    Youtube::Video.import_video!(youtube_video)
    video_ids = Youtube::Video.where(video_id: youtube_video.items.map(&:id)).pluck(:id)
    relateds = video_ids.map do |to_id|
      Youtube::VideoRelated.new(youtube_video_id: self.id, to_youtube_video_id: to_id)
    end
    Youtube::VideoRelated.import(relateds)
  end
end
