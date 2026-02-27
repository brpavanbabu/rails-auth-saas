Rails.application.routes.draw do
  # Authentication
  get "signup", to: "users#new"
  post "signup", to: "users#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # OAuth (OmniAuth)
  match "/auth/:provider/callback", to: "oauth#callback", via: [ :get, :post ]
  get "/auth/failure", to: "oauth#failure"
  delete "/oauth/:provider", to: "oauth#destroy", as: :unlink_oauth

  # Two-Factor Authentication
  namespace :two_factor do
    get :setup
    post :enable
    get :verify
    post :verify
    post :disable
  end

  # SAML SSO
  scope :auth do
    scope :saml do
      get "/:account_id", to: "saml#initiate", as: :saml_initiate
      post "/:account_id/callback", to: "saml#callback", as: :saml_callback
      get "/:account_id/metadata", to: "saml#metadata", as: :saml_metadata
    end
  end

  # LTI 1.3 (EdTech)
  scope :lti do
    get "/oidc_login", to: "lti13#oidc_login", as: :lti_oidc_login
    post "/launch", to: "lti13#launch", as: :lti_launch
    get "/jwks/:registration_id", to: "lti13#jwks", as: :lti_jwks
  end

  # Admin
  namespace :admin do
    resources :saml_providers
  end

  # Dashboard
  get "dashboard", to: "dashboard#show"

  root "sessions#new"
end
