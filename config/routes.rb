Rails.application.routes.draw do

  namespace :api do
    resources :sessions, only: %i[create]
    delete :logout, to: 'sessions#logout'
    get :logged_in, to: 'sessions#logged_in'
    get :anything, to: 'sessions#anything'
    resources :registrations, only: %i[create]
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
