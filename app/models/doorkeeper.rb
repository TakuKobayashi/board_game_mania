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

class Doorkeeper < Event
  DOORKEEPER_URL = "https://api.doorkeeper.jp/events"

  def self.find_event(keywords:, page: 1)
    return RequestParser.request_and_parse_json(url: DOORKEEPER_URL, params: {q: keywords.join("|"), page: page})
  end

  def self.import_events!
    page = 1
    begin
      events_response = Doorkeeper.find_event(keywords: Event::BOARDGAME_KEYWORDS + ["BoardGame", "AnalogGame"], page: page)
      events_response.each do |res|
        event = res["event"]
        doorkeeper_event = Doorkeeper.find_or_initialize_by(event_id: event["id"].to_s)
        doorkeeper_event.attributes = doorkeeper_event.attributes.merge({
          title: event["title"].to_s,
          url: event["public_url"].to_s,
          description: ApplicationRecord.basic_sanitize(event["description"].to_s),
          limit_number: event["ticket_limit"],
          address: event["address"].to_s,
          place: event["venue_name"].to_s,
          lat: event["lat"],
          lon: event["long"],
          owner_id: event["group"]
        })
        doorkeeper_event.started_at = DateTime.parse(event["starts_at"])
        doorkeeper_event.ended_at = DateTime.parse(event["ends_at"]) if event["ends_at"].present?
        doorkeeper_event.set_location_data
        doorkeeper_event.save!
      end
      page += 1
    end while events_response.present?
  end
end
