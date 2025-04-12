Rails.application.routes.draw do
  # Authentication routes
  devise_for :users

  # Application routes
  resources :households, only: [:index, :show, :create, :update, :destroy] do
    resources :rooms, only: [:index, :show, :create] do
      resources :boxes, only: [:index, :show, :create] do
        resources :tags, only: [:index, :create]
        resources :items, only: [:index, :show, :create]
      end
    end
    resources :boxes, only: [:index, :show]
    resources :tags, only: [:index, :show, :create]
    resources :items, only: [:index, :show]
  end
  resources :rooms, only: [:update, :destroy]
  resources :boxes, only: [:update, :destroy]
  resources :tags, only: [:update, :destroy]
  resources :items, only: [:update, :destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "households#index"
end
