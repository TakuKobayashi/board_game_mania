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

class Atnd < Event
  ATND_API_URL = "http://api.atnd.org/events/"
  ATND_EVENTPAGE_URL = "https://atnd.org/events/"

  def self.find_event(keywords:, start: 1)
    return RequestParser.request_and_parse_json(url: ATND_API_URL, params: {keyword_or: keywords, count: 100, start: start, format: :json})
  end

  def self.import_events!
    start = 1
    begin
      events_response = Atnd.find_event(keywords: Event::BOARDGAME_KEYWORDS + ["BoardGame", "AnalogGame"], start: start)
      start += events_response["results_returned"]
      current_events = Atnd.where(event_id: events_response["events"].map{|res| res["event"]["event_id"]}.compact).index_by(&:event_id)
      transaction do
        events_response["events"].each do |res|
          event = res["event"]
          if current_events[event["event_id"].to_s].present?
            atnd_event = current_events[event["event_id"].to_s]
          else
            atnd_event = Atnd.new(event_id: event["event_id"].to_s)
          end
          atnd_event.merge_attributes_and_set_location_data(attrs: {
            event_id: event["event_id"].to_s,
            title: event["title"].to_s,
            url: ATND_EVENTPAGE_URL + event["event_id"].to_s,
            description: Sanitizer.basic_sanitize(event["description"].to_s),
            limit_number: event["limit"],
            address: event["address"].to_s,
            place: event["place"].to_s,
            lat: event["lat"],
            lon: event["lon"],
            owner_id: event["owner_id"],
            owner_nickname: event["owner_nickname"],
            started_at: event["started_at"],
            ended_at: event["ended_at"]
          })
          atnd_event.save!
        end
      end
    end while events_response["events"].present?
  end
end
