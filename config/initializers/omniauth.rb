# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV.fetch("GOOGLE_CLIENT_ID", "dummy_id"),
    ENV.fetch("GOOGLE_CLIENT_SECRET", "dummy_secret"),
    scope: "email,profile",
    prompt: "select_account"

  provider :github,
    ENV.fetch("GITHUB_CLIENT_ID", "dummy_id"),
    ENV.fetch("GITHUB_CLIENT_SECRET", "dummy_secret"),
    scope: "user:email"
end

OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true
