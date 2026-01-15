Rails.application.routes.draw do
  # ActiveStorage routes for file uploads (free local storage)
  # These routes are needed for serving uploaded images
  # In Rails 7.2, these are auto-mounted, but we ensure they're available
  # ActiveStorage routes are automatically mounted by Rails, but we can verify they exist
  
  # ActiveAdmin routes - uses User model with role-based auth
  # AdminUser routes are kept for backward compatibility but not used
  # devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

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

  # OmniAuth callbacks must be outside the locale scope
  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Locale scope for public routes
  scope "(:locale)", locale: /en|hi|kn|ml/ do
    # Public sign in / sign up
    devise_for :users, skip: :omniauth_callbacks, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }


    # Public routes
    resources :tournaments, only: [:show], param: :slug, path: 'tournaments' do
      member do
        post :like
        delete :unlike
      end
    end

    # Static pages
    get 'privacy-policy', to: 'static#privacy_policy'
    get 'terms-conditions', to: 'static#terms_conditions'
    get 'about', to: 'static#about'
    get 'contact', to: 'static#contact'

    root 'home#index'
  end
end

