require 'api_constraints'

Rails.application.routes.draw do
  # API client routes
  root             'static_pages#home'
  get 'about'   => 'static_pages#about'
  get 'help'    => 'static_pages#help'
  get 'contact' => 'static_pages#contact'

  # RESTful API routes
  namespace :api, defaults: { format: :json },
                  constraints: { subdomain: 'api' }, path: '/' do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users,       only: [:show, :index, :create, :update, :destroy]
      resources :sessions,    only: [:create, :destroy]
      resources :podcasts,    only: [:show, :index, :create, :update, :destroy] do
        resources :timestamps,  only: [:create]
      end
      resources :timestamps,  only: [:show, :index, :update, :destroy]
      resources :articles,    only: [:show, :index, :create, :update, :destroy]
    end
  end
end
