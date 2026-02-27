require "application_system_test_case"

class LogoutTest < ApplicationSystemTestCase
  test "user can log out successfully" do
    user = User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")
    
    visit "/login"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in"
    
    assert_text "Welcome back!"
    
    click_button "Log out"
    
    assert_text "You have been logged out."
  end
end
