Rails.application.routes.draw do
  root 'home#index'
  resources :brands, only: %i[show new edit create update destroy], param: :name, constraints: { name: /[^\/]+/ }
  resources :items, only: %i[show new edit create update destroy], param: :name, constraints: { name: /[^\/]+/ }
  resources :lines, only: %i[show new edit create update destroy], param: :name, constraints: { name: /[^\/]+/ }
  resources :knowledges
  resources :magazines, path: '/magazine'
  resources :tags, only: [:show], constraints: { id: /[^\/]+/ }
  resources :brands do
    resources :lines, only: [:index]
  end
  resources :users, only: [:show]
  resources :terms, only: %i[index new edit create update destroy]
  resources :categories, only: %i[index edit update destroy]
  namespace :terms do
    get '/:category_name', to: 'categories#show', as: 'category', constraints: { category_name: /[^\/]+/ }
  end

  get 'products/:knowledge_id', to: 'products#show', as: 'product'

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete '/logout', to: 'sessions#destroy'

  get '/about', to: 'home#about'
  get '/tos', to: 'home#tos', as: 'tos'
  get '/privacy_policy', to: 'home#privacy_policy', as: 'privacy_policy'

  get '/admin', to: 'admin#show'
  namespace :admin do
    resources :magazines, only: [:index], path: '/magazine'
    resources :shops, only: %i[index new create edit update destroy]
  end

  namespace :api, defaults: { format: :json } do
    resources :terms, only: [:index]
    resources :knowledges, only: %i[index show]
    resources :magazines, only: %i[index], path: '/magazine'
    resources :products, only: [:show]
    resources :tags, only: [:index]
    resources :shops, only: [:index]
    resources :image_credits, only: [:create]
  end

  match '*path', to: 'application#routing_error', via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
