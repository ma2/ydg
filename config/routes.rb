Rails.application.routes.draw do
  get 'oosama/index'

  resources :users
  post 'ydg/callback', to: 'api#callback'
  # テスト用
  get 'ydg/callback', to: 'api#callback'
end
