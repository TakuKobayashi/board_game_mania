class DropTableYoutubeTagsAndYoutubeRelations < ActiveRecord::Migration[6.0]
  def change
    drop_table :youtube_video_relateds
    drop_table :youtube_video_tags
  end
end
