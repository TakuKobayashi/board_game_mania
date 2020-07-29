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
  include EventCommon

  enum state: { active: 0, unactive: 1, closed: 2 }
  enum informed_from: { web: 0, connpass: 1, atnd: 2, doorkeeper: 3, peatix: 4, meetup: 5, google_form: 6, twitter: 7 }

  BOARDGAME_KEYWORDS = ["人狼", "ボドゲ", "ボードゲーム", "ぼーどげーむ", "boardgame", "アナログゲーム", "あなろぐげーむ", "analoggame"]
  BOARDGAME_CHECK_SEARCH_KEYWORD_POINTS = {
    "人狼" => 3,
    "ボドゲ" => 3,
    "ボードゲーム" => 3,
    "boardgame" => 3,
    "analoggame" => 3,
    "ゲーム" => 2
  }

  before_save do
    if self.url.size > 255
      shorted_url = self.get_short_url
      self.url = shorted_url
      self.shortener_url = shorted_url
    end
  end

  def self.import_events!
    keywords = HACKATHON_KEYWORDS + %w[はっかそん]
    # マルチスレッドで処理を実行するとCircular dependency detected while autoloading constantというエラーが出るのでその回避のためあらかじめeager_loadする
    Rails.application.eager_load!
    operation_modules = [ConnpassOperation, DoorkeeperOperation, PeatixOperation]
    Parallel.each(operation_modules, in_threads: operation_modules.size) do |operation_module|
      operation_module.import_events_from_keywords!(keywords: keywords)
    end
    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start
    self.import_events_from_twitter!
    GoogleFormEventOperation.load_and_imoport_events!(refresh_token: ENV.fetch('GOOGLE_OAUTH_BOT_REFRESH_TOKEN', ''))
  end

  def self.import_events_from_twitter!
    TwitterEventOperation.import_events_from_keywords!(
      keywords: Event::TWITTER_HACKATHON_KEYWORDS,
      options: { limit_execute_second: 3600, default_max_tweet_id: nil },
    )
  end

  def distribute_event_type
    # TODO アイディアソンもここで振り分けたい
    if self.boardgame_event?
      self.type = BoardgameEvent.to_s
    else
      self.type = nil
    end
  end

  def output_url
    if self.short_url.present?
      return self.short_url
    else
      return self.url
    end
  end

  def boardgame_event?
    return self.boardgame_event_confidence_score >= 9
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

  def generate_tweet_text
    tweet_words = [self.title, self.output_url]
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

  def self.export_frontend_masterdata_json
    future_events = Event.where("? < started_at AND started_at < ?", Time.current, 1.year.since).order("started_at ASC").select{|event| event.boardgame_event? }
    events_hash = future_events.map do |event|
      end_at_string = if event.ended_at.blank?
        ""
      elsif event.ended_at.day == event.started_at.day
        event.ended_at.strftime("%H:%M")
      else
        event.ended_at.strftime("%Y/%m/%d(#{%w(日 月 火 水 木 金 土)[event.started_at.wday]})%H:%M")
      end
      {
        title: event.title,
        url: event.url.to_s,
        place: event.place.to_s,
        address: event.address.to_s,
        started_at: event.started_at.strftime("%Y/%m/%d(#{%w(日 月 火 水 木 金 土)[event.started_at.wday]})%H:%M"),
        end_at: end_at_string,
      }
    end
    video_ids = Youtube::VideoTag.where(tag: Event::BOARDGAME_KEYWORDS - ["人狼"]).pluck(:youtube_video_id).uniq.sample(100)
    videos = Youtube::Video.where(id: video_ids)
    json_hash = {
      videos: videos.map{|video| {url: video.embed_url} },
      events: events_hash
    }
    File.write(Rails.root.join("frontend", "public", "master_data.json"), json_hash.to_json)
  end
end
