Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {registrations: "users/registrations"}
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # root 'home#index'
  root 'home#dashboard'
  get 'dashboard', controller: 'home', action: 'dashboard'
  get 'welcome', controller: 'home', action: 'welcome'
  get 'connect-account', controller: 'home', action: 'connect_account'
  get 'verify-account', controller: 'home', action: 'verify_account'
  post 'users/add_target_account', controller: 'users', action: 'add_target_account'
  post 'users/delete_target_account', controller: 'users', action: 'delete_target_account'
  resources :subscriptions do
    member do
      post 'cancel'
      get 'upgrade_plan'
      post 'upgrade'
    end
  end

  resources :users, only: [] do
    member do
      post 'add_instagram_account'
      post 'verify_instagram_account'
      post 'add_similar_account'
      post 'remove_similar_account'
    end

    collection do
      get 'validation_email'
      get 'account_info'
      get 'growth_performance'
      get 'target_performance'
      get 'top_engagers'
      get 'target_accounts'
    end
  end
end
