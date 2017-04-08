require 'google/apis/youtube_v3'

namespace :crawl do
  task youtube: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    page_token = ExtraInfo.read_extra_info[Youtube::Video.table_name]
    retry_counter = 0
    begin
      begin
        youtube_search = youtube.list_searches("id,snippet", max_results: 50, region_code: "JP",  type: "video", q: "ボードゲーム", page_token: page_token)
        youtube_video = youtube.list_videos("id,snippet,statistics", max_results: 50, id: youtube_search.items.map{|item| item.id.video_id}.join(","))
        Youtube::Video.import_video!(youtube_video)

        if youtube_search.next_page_token.blank?
          page_token = nil
        else
          page_token = youtube_search.next_page_token
        end
        ExtraInfo.update({Youtube::Video.table_name => page_token})
      rescue Exception => e
        logger = ActiveSupport::Logger.new("log/batch_error.log")
        console = ActiveSupport::Logger.new(STDOUT)
        logger.extend ActiveSupport::Logger.broadcast(console)
        logger.info("error message:#{e.message.to_s}")
        puts "error message:" + e.message,to_s
      end
    end while page_token.present?
  end
end