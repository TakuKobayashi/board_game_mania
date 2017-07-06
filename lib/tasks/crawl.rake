require 'google/apis/youtube_v3'

namespace :crawl do
  task youtube: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    page_token = ExtraInfo.read_extra_info[Youtube::Video.table_name]
    begin
      youtube_search = youtube.list_searches("id,snippet", max_results: 50, region_code: "JP",  type: "video", q: "ボードゲーム", page_token: page_token)
      youtube_video = youtube.list_videos("id,snippet,statistics", max_results: 50, id: youtube_search.items.map{|item| item.id.video_id}.join(","))
      Youtube::Video.import_video!(youtube_video)
      videos = Youtube::Video.where(video_id: youtube_search.items.map{|item| item.id.video_id})
      videos.each do |video|
        youtube_search_related = youtube.list_searches("id,snippet", max_results: 50, region_code: "JP",  type: "video", related_to_video_id: video.video_id, page_token: page_token)
        if youtube_search_related.items.present?
          video_related = youtube.list_videos("id,snippet,statistics", max_results: 50, id: youtube_search_related.items.map{|item| item.id.video_id}.join(","))
          video.import_related_video!(video_related)
        end
      end
      if youtube_search.next_page_token.blank?
        page_token = nil
      else
        page_token = youtube_search.next_page_token
      end
      ExtraInfo.update({Youtube::Video.table_name => page_token})
    end while page_token.present?
  end

  task event_crawl: :environment do
    Event.import_events!
  end
end