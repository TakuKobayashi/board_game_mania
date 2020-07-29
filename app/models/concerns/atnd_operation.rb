module AtndOperation
  ATND_API_URL = 'http://api.atnd.org/events/'
  ATND_EVENTPAGE_URL = 'https://atnd.org/events/'

  def self.find_event(keywords:, start: 1)
    return(
      RequestParser.request_and_parse_json(
        url: ATND_API_URL, params: { keyword_or: keywords, count: 100, start: start, format: :json },
      )
    )
  end

  def self.import_events_from_keywords!(keywords:)
    start = 1
    begin
      events_response = self.find_event(keywords: keywords, start: start)
      start += events_response['results_returned']
      current_events =
        Event.atnd.where(event_id: events_response['events'].map { |res| res['event']['event_id'] }.compact).index_by(
          &:event_id
        )
      events_response['events'].each do |res|
        Event.transaction do
          event = res['event']
          if current_events[event['event_id'].to_s].present?
            atnd_event = current_events[event['event_id'].to_s]
          else
            atnd_event = Event.new(event_id: event['event_id'].to_s)
          end
          atnd_event.merge_event_attributes(
            attrs: {
              informed_from: :atnd,
              title: event['title'].to_s,
              url: ATND_EVENTPAGE_URL + event['event_id'].to_s,
              description: Sanitizer.basic_sanitize(event['description'].to_s),
              limit_number: event['limit'],
              address: event['address'],
              place: event['place'].to_s,
              lat: event['lat'],
              lon: event['lon'],
              owner_id: event['owner_id'],
              owner_nickname: event['owner_nickname'],
              started_at: event['started_at'],
              ended_at: event['ended_at'],
            },
          )
          atnd_event.save!
        end
      end
    end while events_response['events'].present?
  end
end
