class GithubController < ApplicationController
  protect_from_forgery

  def hook
    params.permit!
    logger.info param
    head(:ok)
  end

end
