class DiceController < ApplicationController
  def index
    video = Youtube::Video.offset(rand(Youtube::Video.count)).first

    events = Connpass.find_event("ボードゲーム")

    @response = {
      video: { id: video&.video_id },
      relatedVideo: video&.video_related&.sample(3)&.map { |related|
        rel_video = Youtube::Video.find(related.to_youtube_video_id)
        {
          id: rel_video.video_id,
          thumnail: rel_video.thumnail_image_url
        }
      },
      eventPages: events&.sample(3).map { |event|
        {
          url: event[:event_url],
          description: event[:title],
          place: "#{event[:address]} #{event[:place]}",
          startedAt: event[:started_at].strftime("%Y-%m-%d %H:%M〜")
        }
      }
    }
  end
end
