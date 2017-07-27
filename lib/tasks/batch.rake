namespace :batch do
  task bot_tweet: :environment do
    future_events = Event.where("? < started_at AND started_at < ?", Time.current, 1.year.since).order("started_at ASC")
    future_events.each do |event|
      if !TwitterBot.exists?(from: event)
        TwitterBot.tweet!(text: event.generate_tweet_text, from: event, options: {lat: event.lat, long: event.lon})
      end
    end
  end
end