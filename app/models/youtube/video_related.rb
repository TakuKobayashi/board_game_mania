# == Schema Information
#
# Table name: youtube_video_relateds
#
#  id                  :integer          not null, primary key
#  youtube_video_id    :integer          not null
#  to_youtube_video_id :integer          not null
#
# Indexes
#
#  index_youtube_video_relateds_on_to_youtube_video_id  (to_youtube_video_id)
#  index_youtube_video_relateds_on_youtube_video_id     (youtube_video_id)
#

class Youtube::VideoRelated < ApplicationRecord
  belongs_to :video, class_name: 'Youtube::Video', foreign_key: :youtube_video_id, required: false
  belongs_to :to_video, class_name: 'Youtube::Video', foreign_key: :to_youtube_video_id, required: false
end
