class DiceController < ApplicationController
  def index
    video_id = Youtube::VideoTag.where(tag: Event::BOARDGAME_KEYWORDS).pluck(:youtube_video_id).uniq.sample
    @video = Youtube::Video.find_by(id: video_id)
    @events = Event.where("? < started_at AND started_at < ?", Time.current, 1.year.since).select{|event| event.boardgame_event? }.sample(5).sort_by(&:started_at)
  end
end
