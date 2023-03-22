Rails.application.routes.draw do
  root 'pages#home'
  get 'about', to: 'pages#about'
  #resources :articles, only: [:show, :index, :new, :create, :edit, :update]
  resources :articles
  #resources :users, only: [:new, :create]
  get 'signup', to: 'users#new'
  #post 'users', to: 'users#create'
  resources :users, except: [:new]
  
end
