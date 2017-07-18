# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  event_id       :string(255)
#  type           :string(255)
#  title          :string(255)      not null
#  url            :string(255)      not null
#  shortener_url  :string(255)
#  description    :text(65535)
#  started_at     :datetime         not null
#  ended_at       :datetime
#  limit_number   :integer
#  address        :string(255)      not null
#  place          :string(255)      not null
#  lat            :float(24)
#  lon            :float(24)
#  owner_id       :string(255)
#  owner_nickname :string(255)
#  owner_name     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_events_on_event_id_and_type        (event_id,type) UNIQUE
#  index_events_on_started_at_and_ended_at  (started_at,ended_at)
#  index_events_on_title                    (title)
#

require 'google/apis/urlshortener_v1'

class Event < ApplicationRecord
  geocoded_by :address, latitude: :lat, longitude: :lon
  after_validation :geocode

  before_save do
    self.address = Charwidth.normalize(self.address)
  end

  BOARDGAME_KEYWORDS = ["ボードゲーム", "ぼーどげーむ", "boardgame", "アナログゲーム", "あなろぐげーむ", "analoggame"]

  def boardgame_event?
    sanitized_title = ApplicationRecord.basic_sanitize(self.title).downcase
    return Event::BOARDGAME_KEYWORDS.any?{|word| sanitized_title.include?(word) }
  end

  def self.import_events!
    Connpass.import_events!
    Doorkeeper.import_events!
    Atnd.import_events!
  end

  def short_url
    if shortener_url.blank?
      convert_to_short_url!
    end
    return self.shortener_url
  end

  def convert_to_short_url!
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    service = Google::Apis::UrlshortenerV1::UrlshortenerService.new
    service.key = apiconfig["google"]["apikey"]
    url_obj = Google::Apis::UrlshortenerV1::Url.new
    url_obj.long_url = self.url
    result = service.insert_url(url_obj)
    update!(shortener_url: result.id)
  end

  def generate_tweet_text
     tweet_words = [self.title, self.short_url, self.started_at.strftime("%Y年%m月%d日")]
     tweet_words += ["#ボードゲーム", "#アナログゲーム", "#boardgame", "#analoggame", "#boardgames", "#analoggames"]
     text_size = 0
     tweet_words.select! do |text|
       text_size += text.size
       text_size <= 140
     end
     return tweet_words.join("\n")
  end
end
