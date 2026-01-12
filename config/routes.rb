Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  namespace :api do
    namespace :v1 do
      resources :sports, only: [:index, :show]
      resources :tournaments, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get :nearby
          get :by_pincode
        end
        member do
          put :publish
        end
      end
      resources :teams, only: [:index, :show, :create, :update, :destroy]
      resources :venues, only: [:index, :show, :create, :update]
      resources :users, only: [:show, :update] do
        collection do
          post :send_otp
          post :verify_otp
        end
      end
    end
  end

  # Public routes
  resources :tournaments, only: [:show], param: :slug, path: 'tournaments'
  
  root 'home#index'
end

