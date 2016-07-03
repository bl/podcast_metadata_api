require 'api_constraints'

Rails.application.routes.draw do

  namespace :api, defaults: { format: :json },
                  constraints: { subdomain: 'api' }, path: '/' do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users,               only: [:show, :index, :create, :update, :destroy] do
        resources :series,              only: [:index]
        resources :podcasts,            only: [:index]
        resources :articles,            only: [:index]
      end
      resources :sessions,            only: [:create, :destroy]
      resources :account_activations, only: [:create, :edit]
      resources :password_resets, only: [:show, :create, :update]
      resources :series,              only: [:show, :index, :create, :update, :destroy] do
        resources :podcasts,            only: [:index, :create]
        member do
          post :publish
          delete :unpublish
        end
      end
      resources :podcasts,            only: [:show, :index, :create, :update, :destroy] do
        resources :timestamps,          only: [:index, :create]
        member do
          post :publish
          delete :unpublish
          post :upload
        end
      end
      resources :timestamps,          only: [:show, :update, :destroy]
      resources :articles,            only: [:show, :index, :create, :update, :destroy] do
        member do
          post :publish
          delete :unpublish
        end
      end
    end
  end


  scope module: "api/v1", constraints: ApiConstraints.new(version: 1, default: true) do
    resources :podcasts, only: [:show, :create] do
      member do
        get :upload
        post :upload
      end
    end
  end
end
