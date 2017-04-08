class DiceController < ApplicationController
  def index
  end

  def dice
    render json: Connpass.find_event("ボードゲーム")
  end
end
