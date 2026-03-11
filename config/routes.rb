Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :games, only: [:index, :show] do
    resources :patches, only: [:index]
  end
  resources :patches, only: [:index, :show] do
    member do
      post :generate_summary
    end
    resources :chats, only: [:create] do
      resources :messages, only: [:create]
    end
  end
  resources :events, only: [:index, :show] do
    member do
      post :generate_summary
    end
  end
  resources :favourites, only: [:create, :destroy]
  resources :reminders, only: [:create, :destroy]

  resources :users, only: [:index]

  get "find-friends", to: "pages#find_friends", as: :find_friends
  get "my-profile", to: "pages#my_profile", as: :my_profile
  get "home", to: "pages#home"

  root "pages#home"

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#server_error", via: :all
end
