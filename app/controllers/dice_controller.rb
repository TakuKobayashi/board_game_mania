class DiceController < ApplicationController
  def index
    @video = Youtube::Video.where("id >= ?", rand(Youtube::Video.last.id)).first
    @events = Event.where("? < started_at AND started_at < ?", Time.current, 1.year.since).order("started_at ASC").select{|event| event.hackathon_event? }
  end
end
