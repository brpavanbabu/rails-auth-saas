require "test_helper"

class UsersRequestTest < ActionDispatch::IntegrationTest
  test "create action creates user and redirects" do
    assert_difference "User.count", 1 do
      post signup_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Welcome! You have signed up successfully", response.body
  end

  test "create action fails with invalid data" do
    assert_no_difference "User.count" do
      post signup_path, params: {
        user: {
          email: "invalid-email",
          password: "short",
          password_confirmation: "short"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_match "prohibited this user from being saved", response.body
  end
end
