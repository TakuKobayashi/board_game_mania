Rails.application.routes.draw do
  get '/' => 'dice#index'

  get '/dice' => 'dice#dice'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
