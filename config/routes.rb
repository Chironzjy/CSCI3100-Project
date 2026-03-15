Rails.application.routes.draw do
  devise_for :users

  resources :items do
    member do
      patch :update_status
    end
  end

  get 'my_items', to: 'items#my_items', as: :my_items

  root 'home#index'
end
