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
      resources :series,              only: [:show, :index, :create, :update, :destroy] do
        resources :podcasts,            only: [:index, :create]
      end
      resources :podcasts,            only: [:show, :index, :create, :update, :destroy] do
        resources :timestamps,          only: [:index, :create]
      end
      resources :timestamps,          only: [:show, :update, :destroy]
      resources :articles,            only: [:show, :index, :create, :update, :destroy]
    end
  end
end
