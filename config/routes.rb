Rails.application.routes.draw do
  post 'ydg/callback', to: 'api#callback'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
