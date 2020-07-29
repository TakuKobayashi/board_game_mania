class DiceController < ApplicationController
  def index
    @video = Youtube::Video.all.sample
    @events = Event.where("? < started_at AND started_at < ?", Time.current, 1.year.since).select{|event| event.boardgame_event? }.sample(5).sort_by(&:started_at)
  end
end
