class GithubController < ApplicationController
  protect_from_forgery

  def hook
    params.permit!
    logger.info params
    call_hash = JSON.parse(params[:payload])
    if call_hash["repository"]["full_name"] == "TakuKobayashi/board_game_mania"
      system("nohup cd " + Rails.root.to_s + " | sh " + Rails.root.to_s + "/deploy_from_system.sh")
    end
    head(:ok)
  end
end
