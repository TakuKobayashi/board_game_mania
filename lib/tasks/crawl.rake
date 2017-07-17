require 'google/apis/youtube_v3'

namespace :crawl do
  task youtube: :environment do
    youtube = Youtube.get_api
    Event::BOARDGAME_KEYWORDS.each do |keyword|
      tokenjsonkey = [keyword, Youtube::Video.table_name].join("_")
      Youtube.loop_crawl(tokenjsonkey) do |page_token|
        youtube_search = youtube.list_searches("id,snippet", max_results: 50, region_code: "JP",  type: "video", q: keyword, page_token: page_token, video_embeddable: true)
        youtube_video = youtube.list_videos("id,snippet,statistics", max_results: 50, id: youtube_search.items.map{|item| item.id.video_id}.join(","))
        Youtube::Video.import_video!(youtube_video: youtube_video)
        youtube_search.next_page_token
      end
    end
  end

  task youtube_rewlated_video: :environment do
    youtube = Youtube.get_api
    Youtube::Video.where(is_related: false).find_in_batches(batch_size: 50) do |videos|
      videos.each do |video|
        tokenjsonkey = [video.video_id, Youtube::Video.table_name, "related"].join("_")
        Youtube.loop_crawl(tokenjsonkey) do |page_token|
          youtube_search_related = youtube.list_searches("id,snippet", max_results: 50, region_code: "JP",  type: "video", related_to_video_id: video.video_id, page_token: page_token, video_embeddable: true)
          if youtube_search_related.items.present?
            video_related = youtube.list_videos("id,snippet,statistics", max_results: 50, id: youtube_search_related.items.map{|item| item.id.video_id}.join(","))
            video.import_related_video!(youtube_video: video_related)
          end
          youtube_search_related.next_page_token
        end
      end
    end
  end

  task event: :environment do
    Event.import_events!
  end
end