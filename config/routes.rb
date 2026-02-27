Rails.application.routes.draw do
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # OAuth (OmniAuth convention: /auth/:provider, /auth/:provider/callback)
  match "/auth/:provider/callback", to: "oauth#callback", via: [:get, :post]
  get "/auth/failure", to: "oauth#failure"
  delete "/oauth/:provider", to: "oauth#destroy", as: :unlink_oauth

  # SAML SSO
  scope :auth do
    scope :saml do
      get "/:account_id", to: "saml#initiate", as: :saml_initiate
      post "/:account_id/callback", to: "saml#callback", as: :saml_callback
      get "/:account_id/metadata", to: "saml#metadata", as: :saml_metadata
    end
  end

  # LTI 1.3 (EdTech Learning Tools Interoperability)
  scope :lti do
    get "/oidc_login", to: "lti13#oidc_login", as: :lti_oidc_login
    post "/launch", to: "lti13#launch", as: :lti_launch
    get "/jwks/:registration_id", to: "lti13#jwks", as: :lti_jwks
    resources :platforms, controller: "lti13/platforms"
    resources :resource_links, controller: "lti13/resource_links" do
      resources :grades, controller: "lti13/grades"
    end
  end

  # Admin (SAML Provider Management)
  namespace :admin do
    resources :saml_providers
    resources :audit_logs, only: [:index, :show]
    resources :transaction_logs, only: [:index, :show]
    resources :security_events, only: [:index, :show, :update]
    resources :lti_platforms
    
    # Compliance Reports
    get "compliance/hipaa", to: "compliance#hipaa_report"
    get "compliance/pci", to: "compliance#pci_report"
    get "compliance/soc2", to: "compliance#soc2_report"
  end

  get "dashboard", to: "dashboard#show"

  namespace :two_factor do
    get :setup
    post :enable
    get :verify
    post :verify
    post :disable
  end

  # Temporary root for testing
  root "users#new"
end
