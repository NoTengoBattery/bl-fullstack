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

  # About page
  get 'about', to: 'about#index', as: :about

  # Defines the root path route ("/")
  root 'home#index'
end
