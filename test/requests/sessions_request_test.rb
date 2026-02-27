require "test_helper"

class SessionsRequestTest < ActionDispatch::IntegrationTest
  test "create action logs in user" do
    user = User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123")

    post login_path, params: { email: "user@example.com", password: "password123" }

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Welcome back!", response.body
  end

  test "create action fails with wrong password" do
    user = User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123")

    post login_path, params: { email: "user@example.com", password: "wrongpassword" }

    assert_response :unprocessable_entity
    assert_match "Invalid email or password", response.body
  end

  test "destroy action logs out user" do
    user = User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123")
    post login_path, params: { email: "user@example.com", password: "password123" }

    delete logout_path

    assert_redirected_to login_path
    follow_redirect!
    assert_match "You have been logged out", response.body
  end
end
