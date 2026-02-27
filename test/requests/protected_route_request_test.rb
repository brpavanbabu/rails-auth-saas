require "test_helper"

class ProtectedRouteRequestTest < ActionDispatch::IntegrationTest
  test "dashboard redirects guest to login" do
    get dashboard_path

    assert_redirected_to login_path
    follow_redirect!
    assert_match "You must be logged in to access this page", response.body
  end

  test "dashboard accessible when logged in" do
    user = User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123")
    post login_path, params: { email: "user@example.com", password: "password123" }

    get dashboard_path

    assert_response :success
    assert_match "Welcome to your dashboard", response.body
  end
end
