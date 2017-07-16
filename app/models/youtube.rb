require 'google/apis/youtube_v3'

module Youtube
  def self.table_name_prefix
    'youtube_'
  end

  def self.get_api
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube_api = Google::Apis::YoutubeV3::YouTubeService.new
    youtube_api.key = apiconfig["google_api"]["key"]
    return youtube_api
  end

  def self.loop_crawl(pagetoke_key)
    page_token = ExtraInfo.read_extra_info[pagetoke_key]
    begin
      next_page_token = yield(page_token)
      if next_page_token.blank?
        page_token = nil
      else
        page_token = next_page_token
      end
      ExtraInfo.update({pagetoke_key => next_page_token})
    end while page_token.present?
  end
end
