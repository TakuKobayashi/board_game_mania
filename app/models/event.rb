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

class Event < ApplicationRecord
  before_save do
    self.address = Charwidth.normalize(self.address)
  end

  BOARDGAME_KEYWORDS = ["人狼", "ボドゲ", "ボードゲーム", "ぼーどげーむ", "boardgame", "アナログゲーム", "あなろぐげーむ", "analoggame"]
  BOARDGAME_CHECK_SEARCH_KEYWORD_POINTS = {
    "人狼" => 3,
    "ボドゲ" => 3,
    "ボードゲーム" => 3,
    "boardgame" => 3,
    "analoggame" => 3,
    "ゲーム" => 2
  }

  def boardgame_event?
    return self.boardgame_event_confidence_score >= 9
  end

  def merge_attributes_and_set_location_data(attrs: {})
    ops = OpenStruct.new(attrs.reject{|key, value| value.nil? })
    if ops.started_at.present?
      ops.started_at = DateTime.parse(ops.started_at)
    end
    if ops.ended_at.present?
      ops.ended_at = DateTime.parse(ops.ended_at)
    end
    self.attributes = self.attributes.merge(ops.to_h)
    self.set_location_data
  end

  def boardgame_event_confidence_score
    sanitized_title = Sanitizer.basic_sanitize(self.title).downcase.tr('ぁ-ん','ァ-ン')
    doc = Nokogiri::HTML.parse(self.description)
    des = doc.text.to_s.downcase.tr('ぁ-ん','ァ-ン')
    score = 0
    BOARDGAME_CHECK_SEARCH_KEYWORD_POINTS.each do |word, point|
      if sanitized_title.include?(word)
        score += (point * 3)
      end
      if des.include?(word)
        score += point
      end
    end
    return score
  end

  def self.import_events!
    Connpass.import_events!
    Doorkeeper.import_events!
    Atnd.import_events!
    Peatix.import_events!
  end

  def short_url
    if shortener_url.blank?
      convert_to_short_url!
    end
    return self.shortener_url
  end

  def set_location_data
    if self.address.present? && self.lat.blank? && self.lon.blank?
      geo_result = RequestParser.request_and_parse_json(
        url: "https://maps.googleapis.com/maps/api/geocode/json",
        params: {address: self.address, language: "ja", key: ENV.fetch("GOOGLE_API_KEY", "")}
        )["results"].first
      if geo_result.present?
        self.lat = geo_result["geometry"]["location"]["lat"]
        self.lon = geo_result["geometry"]["location"]["lng"]
      end
    elsif self.address.blank? && self.lat.present? && self.lon.present?
      geo_result = RequestParser.request_and_parse_json(
        url: "https://maps.googleapis.com/maps/api/geocode/json",
        params: {latlng: [self.lat, self.lon].join(","), language: "ja", key: ENV.fetch("GOOGLE_API_KEY", "")}
        )["results"].first
      if geo_result.present?
        searched_address = Charwidth.normalize(Sanitizer.scan_japan_address(geo_result["formatted_address"]).join).
          gsub(/^[0-9【】、。《》「」〔〕・（）［］｛｝！＂＃＄％＆＇＊＋，－．／：；＜＝＞？＠＼＾＿｀｜￠￡￣\(\)\[\]<>{},!? \.\-\+\\~^='&%$#\"\'_\/;:*‼•一]/, "").
          strip.
          split(" ").
          first
        if searched_address.present?
          self.address = searched_address
        end
      end
    end
    if self.address.present?
      self.address = Charwidth.normalize(self.address).strip
    end
  end

  def convert_to_short_url!
    service = Google::Apis::UrlshortenerV1::UrlshortenerService.new
    service.key = ENV.fetch("GOOGLE_API_KEY", "")
    url_obj = Google::Apis::UrlshortenerV1::Url.new
    url_obj.long_url = self.url
    result = service.insert_url(url_obj)
    update!(shortener_url: result.id)
  end

  def generate_tweet_text
    tweet_words = [self.title, self.short_url]
    datetime_range = self.started_at.strftime("%Y/%m/%d(#{%w(日 月 火 水 木 金 土)[self.started_at.wday]})%H:%M")
    if self.ended_at.blank?
      datetime_range = datetime_range + "〜"
    elsif self.ended_at.day == self.started_at.day
      datetime_range = datetime_range + "〜" + self.ended_at.strftime("%H:%M")
    else
      datetime_range = datetime_range + "〜" + self.ended_at.strftime("%Y/%m/%d(#{%w(日 月 火 水 木 金 土)[self.started_at.wday]})%H:%M")
    end
    tweet_words << datetime_range
    tweet_words += ["#ボドゲ", "#ボードゲーム", "#アナログゲーム", "#boardgame", "#analoggame", "#boardgames", "#analoggames"]
    text_size = 0
    tweet_words.select! do |text|
      text_size += text.size + 2
      text_size <= 140
    end
    return tweet_words.join("\n")
  end
end
