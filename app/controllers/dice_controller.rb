class DiceController < ApplicationController
  def index
  end

  def dice
    video = Youtube::Video.offset(rand(Youtube::Video.count)).first

    events = Connpass.find_event("ボードゲーム")

    response = {
      video: { id: video&.video_id },
      relatedVideo: video&.video_related&.sample(3)&.map { |related|
        rel_video = Youtube::Video.find(related.to_youtube_video_id)
        {
          id: rel_video.video_id,
          thumnail: rel_video.thumnail_image_url
        }
      },
      eventPages: events&.sample(3)
    }
    
    render json: response
  end
end
