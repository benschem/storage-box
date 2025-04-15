Rails.application.routes.draw do
  # Authentication routes
  devise_for :users

  # Application routes
<<<<<<< Updated upstream
  resources :houses, only: [:index, :create, :update, :destroy] do
    resources :rooms, only: [:create]
  end

  resources :rooms, only: [:index, :update, :destroy] do
    resources :boxes, only: [:create]
  end

  resources :boxes, only: [:index, :create, :destroy]

  resources :items, only: [:index, :create, :update, :destroy] do
    resources :tags, only: [:create, :destroy]
  end
=======
  resources :households, only: [:index, :create, :update, :destroy]
  resources :rooms, only: [:index, :create, :update, :destroy]
  resources :boxes, only: [:index, :create, :update, :destroy]
  resources :tags, only: [:index, :create, :update, :destroy]
  resources :items, only: [:index, :create, :update, :destroy]
>>>>>>> Stashed changes

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "items#index"
end
