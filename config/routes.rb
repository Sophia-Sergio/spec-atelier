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
      resources :projects
      resources :project_specs, only: %i[show] do
        post 'create_text'
        delete 'remove_text'
        post 'create_product'
        delete 'remove_product'
        get 'specification'
        patch 'edit_text'
        patch 'add_product_image'
        patch 'remove_product_image'
        patch 'reorder_blocks'
        resources :project_specs_blocks, only: %i[create show]
      end
    end

    resources :items, only: %i[index] do
      get 'products'
    end
    get 'items/:item_id/systems', to: 'items#subitems', as: :systems

    get 'products/send_email'

    resources :products, only: %i[show create index update] do
      post 'associate_images'
      delete 'remove_images'
      post 'associate_documents'
      delete 'remove_documents'
      post 'contact_form'
    end



    resources :sections, only: %i[index] do
      get 'items'
      get 'products'
    end

    get 'general/cities'
    get 'configs/project_data'
    get 'configs/room_types_by_project_type'

    resources :brands, only: %i[index show] do
      post 'contact_form'
    end
  end

  post 'auth/google_login_service', to: 'api/sessions#google_auth'

  # get 'auth/failure', to: 'api/sessions#google_auth_failure'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
