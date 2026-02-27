# frozen_string_literal: true

require "test_helper"

class OauthRequestTest < ActionDispatch::IntegrationTest
  def setup
    OmniAuth.config.test_mode = true
  end

  def teardown
    OmniAuth.config.test_mode = false
  end

  def mock_google_auth(uid: "google-123", email: "oauth@example.com", name: "OAuth User")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: {
        email: email,
        name: name
      },
      credentials: { token: "mock-token-123" }
    )
  end

  def mock_github_auth(uid: "github-456", email: "github@example.com", name: "GitHub User")
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: uid,
      info: {
        email: email,
        name: name
      },
      credentials: { token: "mock-token-456" }
    )
  end

  test "GET /auth/google_oauth2/callback creates user when not logged in" do
    mock_google_auth

    assert_difference "User.count", 1 do
      assert_difference "OauthAccount.count", 1 do
        get "/auth/google_oauth2/callback"
      end
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Account created successfully", response.body

    user = User.find_by(email: "oauth@example.com")
    assert user
    assert user.oauth_accounts.exists?(provider: "google_oauth2", uid: "google-123")
  end

  test "GET /auth/github/callback links to existing user when logged in" do
    user = User.create!(email: "existing@example.com", password: "password123", password_confirmation: "password123")
    post login_path, params: { email: "existing@example.com", password: "password123" }

    mock_github_auth(uid: "github-789", email: "existing@example.com")

    assert_no_difference "User.count" do
      assert_difference "OauthAccount.count", 1 do
        get "/auth/github/callback"
      end
    end

    assert_redirected_to dashboard_path
    assert user.oauth_accounts.exists?(provider: "github", uid: "github-789")
  end

  test "GET /auth/github/callback links new OAuth to existing user by email" do
    User.create!(email: "match@example.com", password: "password123", password_confirmation: "password123")
    mock_github_auth(email: "match@example.com", uid: "github-new")

    assert_no_difference "User.count" do
      assert_difference "OauthAccount.count", 1 do
        get "/auth/github/callback"
      end
    end

    user = User.find_by(email: "match@example.com")
    assert user.oauth_accounts.exists?(provider: "github", uid: "github-new")
  end

  test "DELETE /oauth/google_oauth2 unlinks provider when user has password" do
    user = User.create!(email: "unlink@example.com", password: "password123", password_confirmation: "password123")
    user.oauth_accounts.create!(provider: "google_oauth2", uid: "google-unlink")
    post login_path, params: { email: "unlink@example.com", password: "password123" }

    assert_difference "OauthAccount.count", -1 do
      delete unlink_oauth_path("google_oauth2")
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Provider unlinked successfully", response.body
  end

  test "DELETE /oauth/google_oauth2 unlinks when user has multiple OAuth providers" do
    user = User.create!(email: "multi@example.com", password: "password123", password_confirmation: "password123")
    user.oauth_accounts.create!(provider: "google_oauth2", uid: "google-multi")
    user.oauth_accounts.create!(provider: "github", uid: "github-multi")
    post login_path, params: { email: "multi@example.com", password: "password123" }

    assert_difference "OauthAccount.count", -1 do
      delete unlink_oauth_path("google_oauth2")
    end

    assert user.oauth_accounts.exists?(provider: "github", uid: "github-multi")
    assert_not user.oauth_accounts.exists?(provider: "google_oauth2", uid: "google-multi")
  end

  test "DELETE /oauth requires login" do
    delete unlink_oauth_path("google_oauth2")
    assert_redirected_to login_path
  end
end
