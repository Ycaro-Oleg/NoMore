Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  # Commitments
  resources :commitments, only: [:index, :new, :create, :show] do
    patch :complete, on: :member
  end

  # Focus
  resources :focus_sessions, only: [:index, :create], path: "focus" do
    patch :stop, on: :member
  end

  # Dashboard
  root "dashboard#show"
end
