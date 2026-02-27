require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  test "invalid credentials show error message" do
    visit "/login"

    fill_in "Email", with: "wrong@example.com"
    fill_in "Password", with: "wrongpassword"

    click_button "Log in"

    assert_text "Invalid email or password"
  end

  test "user can log in successfully" do
    user = User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")
    
    visit "/login"

    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"

    click_button "Log in"

    assert_text "Welcome back!"
  end
end
