Rails.application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    resources :sessions, only: %i[create]
    put :logout, to: 'sessions#logout'
    get :logged_in, to: 'sessions#logged_in'
    resources :registrations, only: %i[create]

    get :password_forgot, to: 'passwords#forgot'
    get :password_reset, to: 'passwords#reset'

    resources :users, only: %i[update show] do
      get 'projects/search'
      get 'projects/ordered'
      resources :projects
      resources :project_specs, only: %i[] do
        post 'create_text'
      end
    end

    resources :items, only: %i[] do
      get 'products'
    end
    get 'items/:item_id/systems', to: 'items#subitems', as: :systems

    resources :products, only: %i[show create index] do
      post 'associate_images'
      post 'associate_documents'
    end

    resources :sections, only: %i[index] do
      get 'items'
      get 'products'
    end

    get 'general/cities'
    get 'configs/project_data'

    resources :brands, only: %i[index]
    get 'brands/search'
  end

  post 'auth/google_login_service', to: 'api/sessions#google_auth'

  # get 'auth/failure', to: 'api/sessions#google_auth_failure'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
