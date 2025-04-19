Rails.application.routes.draw do
  # Authentication routes
  devise_for :users

  # Application routes
  resources :houses, only: [:index, :create, :update, :destroy]
  resources :rooms, only: [:index, :create, :update, :destroy]
  resources :boxes, only: [:index, :create, :update, :destroy]
  resources :items, only: [:index, :show, :create, :edit, :update, :destroy] do
    resources :tags, only: [:destroy]
  end
  resources :tags, only: [:index, :create, :update]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "items#index"

end
