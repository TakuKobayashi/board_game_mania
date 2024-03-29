module MeetupOperation
  MEETUP_SEARCH_URL = 'https://api.meetup.com/find/upcoming_events'

  PAGE_PER = 100

  def self.find_event(keywords: [])
    return(
      RequestParser.request_and_parse_json(
        url: MEETUP_SEARCH_URL,
        params: { key: ENV.fetch('MEETUP_API_KEY', ''), text: keywords.join('|'), sign: true, page: PAGE_PER },
        options: { follow_redirect: true },
      )
    )
  end

  def self.import_events_from_keywords!(keywords:)
    events_response = self.find_event(keywords: keywords)
    res_events = events_response['events'] || []
    current_events = Event.meetup.where(event_id: res_events.map { |res| res['id'] }.compact).index_by(&:event_id)
    res_events.each do |res|
      Event.transaction do
        if current_events[res['id'].to_s].present?
          meetup_event = current_events[res['id'].to_s]
        else
          meetup_event = Event.new(event_id: res['id'].to_s)
        end
        start_time = Time.at(res['time'].to_i / 1_000)
        if res['duration'].present?
          end_time = start_time + (res['duration'] / 1_000).second
        else
          end_time = start_time + 2.day
        end
        vanue_hash = res['venue'] || {}
        fee_hash = res['fee'] || {}
        group_hash = res['group'] || {}
        meetup_event.attributes =
          meetup_event.attributes.merge_event_attributes(
            attrs: {
              state: :active,
              informed_from: :meetup,
              title: Sanitizer.basic_sanitize(res['name'].to_s),
              url: res['link'].to_s,
              description: Sanitizer.basic_sanitize(res['description'].to_s),
              started_at: start_time,
              ended_at: end_time,
              limit_number: res['rsvp_limit'],
              address: vanue_hash['address_1'],
              place: vanue_hash['name'].to_s,
              lat: vanue_hash['lat'],
              lon: vanue_hash['lon'],
              owner_id: group_hash['id'],
              owner_nickname: group_hash['urlname'],
              owner_name: Sanitizer.basic_sanitize(group_hash['name'].to_s),
            },
          )
        meetup_event.save!
      end
    end
  end
end
