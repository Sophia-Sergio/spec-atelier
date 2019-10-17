Rails.application.routes.draw do

  namespace :api do
    resources :sessions, only: %i[create]
    put :logout, to: 'sessions#logout'
    get :logged_in, to: 'sessions#logged_in'
    get :anything, to: 'sessions#email_testing'
    resources :registrations, only: %i[create]

    get :password_forgot, to: 'passwords#forgot'
    get :password_reset, to: 'passwords#reset'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end