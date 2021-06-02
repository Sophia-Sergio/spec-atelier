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
      member do
        get :stats
        patch :profile_image_upload
      end
      resources :projects do
        resource :project_configs, only: :create
      end
      resources :project_specs, only: %i[show] do
        post 'create_text'
        delete 'remove_text'
        post 'create_product'
        delete 'remove_block'
        get 'specification'
        get  'download_word'
        get 'download_budget'
        patch 'edit_text'
        patch 'add_product_image'
        patch 'remove_product_image'
        member do
          patch 'reorder_blocks'
        end
        resources :project_specs_blocks, only: %i[create show]
      end
    end

    namespace :project_specs do
      get 'my_specifications'
    end

    resources :items, only: %i[index] do
      get 'products'
    end
    resources :subitems, only: %i[index]

    get 'items/:item_id/systems', to: 'items#subitems', as: :systems

    resources :products, except: %i[edit] do
      member do
        post :associate_images
        delete :remove_images
        post :associate_documents
        delete :remove_documents
        post :contact_form
      end
      scope :product_stats, controller: :product_stats do
        patch :update_downloads
      end
    end

    resources :sections, only: %i[index] do
      get 'items'
      get 'products'
    end

    get 'general/cities'
    get 'configs/project_data'
    get 'configs/room_types'

    resources :brands, only: %i[index]
    resources :clients, only: %i[index show] do
      post 'contact_form'
    end
  end

  post 'auth/google_login_service', to: 'api/sessions#google_auth'

  # get 'auth/failure', to: 'api/sessions#google_auth_failure'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
