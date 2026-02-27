require "application_system_test_case"

class ProtectedPageTest < ApplicationSystemTestCase
  test "guest is redirected to login when visiting protected page" do
    visit "/dashboard"

    assert_current_path "/login"
    assert_text "You must be logged in to access this page."
  end

  test "protected page accessible when logged in" do
    user = User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123")

    visit "/login"
    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in"

    visit "/dashboard"
    assert_current_path "/dashboard"
    assert_text "Welcome to your dashboard"
  end
end
