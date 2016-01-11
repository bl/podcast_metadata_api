require 'api_constraints'

Rails.application.routes.draw do
  scope module: :v1,
        defaults: { format: :json },
        constraints: ApiConstraints.new(version: 1, default: true) do
    resources :users,       only: [:show, :index, :create, :update, :destroy] do
      resources :podcasts,    only: [:create, :update, :destroy]
    end
    resources :sessions,    only: [:create, :destroy]
    resources :podcasts,    only: [:show, :index]
    resources :timestamps,  only: [:show, :index]
  end
end
