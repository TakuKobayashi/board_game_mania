class AddColumnTagsToYoutubeVideos < ActiveRecord::Migration[6.0]
  def change
    add_column :youtube_videos, :tags, :text
  end
end
