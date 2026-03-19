Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }
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
    collection do
      post :suggest
    end

    resources :patches, only: [:index]
  end
  resources :patches, only: [:index, :show] do
    member do
      get :notes
      post :generate_summary
    end
    resources :chats, only: [:create] do
      resources :messages, only: [:create]
      member do
        get :stream
      end
    end
  end
  resources :events, only: [:index, :show]
  resources :favourites, only: [:create, :destroy]
  resources :reminders, only: [:create, :destroy]
  resources :friendships, only: [:create, :update, :destroy]

  resources :users, only: [:index, :show] do
    member do
      get :card
    end
  end

  resources :posts, only: [:create, :destroy] do
    resources :likes, only: [:create, :destroy]
  end

  namespace :admin do
    resource :dashboard, only: [:show], controller: :dashboard
    resource :chat_history, only: [:destroy], controller: :chat_histories
    resources :patch_scrapes, only: [:create] do
      collection do
        post :run_all
      end
    end
    resources :event_imports, only: [:create] do
      collection do
        post :run_all
      end
    end
    resources :users, only: [:create, :destroy], controller: :users
    resource :demo_reset, only: [:create], controller: :demo_resets
  end

  get "find-friends", to: "pages#find_friends", as: :find_friends
  get "my-profile", to: "pages#my_profile", as: :my_profile
  get "home", to: "pages#home"

  root "pages#home"

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#server_error", via: :all
end
