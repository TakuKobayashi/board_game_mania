Rails.application.routes.draw do
  get '/' => 'dice#index'

  resource :github, controller: :github, only: [] do
    post 'hook'
  end
end
