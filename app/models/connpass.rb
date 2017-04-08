class Connpass

  CONNPASS_URL = "https://connpass.com/api/v1/event/".freeze

  def self.find_event(keyword)
    require "net/http"
    require "time"

    uri = URI.parse "#{CONNPASS_URL}?keyword=#{URI.escape keyword}"
    JSON.parse(Net::HTTP.get uri)["events"].map { |event|
      {
        event_url: event["event_url"],
        title: event["title"],
        address: event["address"],
        place: event["place"],
        started_at: Time.parse(event["started_at"]),
      }
    }
  end
end
