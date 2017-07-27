class DiceController < ApplicationController
  def index
    plane_videos = Youtube::Video.where(is_related: false)
    @video = plane_videos.where("id >= ?", rand(plane_videos.last.id)).first
    @events = Event.where("? < started_at AND started_at < ?", Time.current, 1.year.since).sample(5).sort_by(&:started_at)
  end
end
