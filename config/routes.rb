Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
  get 'dashboard', controller: 'home', action: 'dashboard'
  resources :subscriptions

  resources :users, only: [] do
    collection do
      get 'validation_email'
    end
  end
end
