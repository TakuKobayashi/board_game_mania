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

class Connpass < Event
  CONNPASS_URL = "https://connpass.com/api/v1/event/"

  def self.find_event(keywords:, start: 1)
    http_client = HTTPClient.new
    response = http_client.get(CONNPASS_URL, {keyword_or: keywords, count: 100, start: start, order: 1}, {})
    return JSON.parse(response.body)
  end

  def self.import_events!
    update_columns = Connpass.column_names - ["id", "type", "shortener_url", "event_id", "created_at"]
    begin
      events_response = Connpass.find_event(keywords: Event::BOARDGAME_KEYWORDS + ["BoardGame", "AnalogGame"], start: start)
      results_available = events_response["results_available"]
      start += events_response["results_returned"]
      connpass_events = []
      events_response["events"].each do |res|
        connpass_event = Connpass.new(
          event_id: res["event_id"].to_s,
          title: res["title"].to_s,
          url: res["event_url"].to_s,
          description: ApplicationRecord.basic_sanitize(res["description"].to_s),
          limit_number: res["limit"],
          address: res["address"].to_s,
          place: res["place"].to_s,
          lat: res["lat"],
          lon: res["lon"],
          owner_id: res["owner_id"],
          owner_nickname: res["owner_nickname"],
          owner_name: res["owner_display_name"]
        )
        connpass_event.started_at = DateTime.parse(res["started_at"])
        connpass_event.ended_at = DateTime.parse(res["ended_at"]) if res["ended_at"].present?
        connpass_events << connpass_event
      end

      Connpass.import!(connpass_events, on_duplicate_key_update: update_columns)
    end while start < results_available
  end
end
