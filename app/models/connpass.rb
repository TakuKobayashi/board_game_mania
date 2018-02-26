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
    return RequestParser.request_and_parse_json(url: CONNPASS_URL, params: {keyword_or: keywords, count: 100, start: start, order: 1})
  end

  def self.import_events!
    start = 1
    results_available = 0
    begin
      events_response = Connpass.find_event(keywords: Event::BOARDGAME_KEYWORDS + ["BoardGame", "AnalogGame"], start: start)
      results_available = events_response["results_available"]
      start += events_response["results_returned"]
      connpass_events = []
      current_events = Connpass.where(event_id: events_response["events"].map{|res| res["event_id"]}.compact).index_by(&:event_id)
      transaction do
        events_response["events"].each do |res|
          if current_events[res["event_id"].to_s].present?
            connpass_event = current_events[res["event_id"].to_s]
          else
            connpass_event = Connpass.new(event_id: res["event_id"].to_s)
          end
          connpass_event.merge_attributes_and_set_location_data(attrs: {
            title: res["title"].to_s,
            url: res["event_url"].to_s,
            description: Sanitizer.basic_sanitize(res["description"].to_s),
            limit_number: res["limit"],
            address: res["address"].to_s,
            place: res["place"].to_s,
            lat: res["lat"],
            lon: res["lon"],
            owner_id: res["owner_id"],
            owner_nickname: res["owner_nickname"],
            owner_name: res["owner_display_name"],
            started_at: res["started_at"],
            ended_at: res["ended_at"]
          })
          connpass_event.save!
        end
      end
    end while start < results_available
  end
end
