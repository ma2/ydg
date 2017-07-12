Rails.application.routes.draw do
  resources :users
  post 'ydg/callback', to: 'api#callback'
  # テスト用
  get 'ydg/callback', to: 'api#callback'
end
