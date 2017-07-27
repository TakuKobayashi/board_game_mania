# == Schema Information
#
# Table name: youtube_video_tags
#
#  id               :integer          not null, primary key
#  youtube_video_id :integer          not null
#  tag              :string(255)      not null
#
# Indexes
#
#  index_youtube_video_tags_on_tag                       (tag)
#  index_youtube_video_tags_on_youtube_video_id_and_tag  (youtube_video_id,tag) UNIQUE
#

class Youtube::VideoTag < ApplicationRecord
  belongs_to :video, class_name: 'Youtube::Video', foreign_key: :youtube_video_id, required: false

  def sharp
    self.tag = self.tag.downcase.tr('ぁ-ん','ァ-ン')
  end
end
