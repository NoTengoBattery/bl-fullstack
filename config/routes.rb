# frozen_string_literal: true

Rails.application.routes.draw do
  Healthcheck.routes(self)

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Authentication routes
  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :logout

  get 'register', to: 'registrations#new', as: :register
  post 'register', to: 'registrations#create'

  # Dashboard
  get 'dashboard', to: 'dashboard#index', as: :dashboard

  # Books
  resources :books

  # Borrowings
  resources :borrowings, only: %i[index show create update]

  # Defines the root path route ("/")
  root 'books#index'
end
