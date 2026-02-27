require "application_system_test_case"

class SignupTest < ApplicationSystemTestCase
  test "user can sign up successfully" do
    visit "/signup"

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    assert_text "Welcome! You have signed up successfully."
  end

  test "signup fails with errors displayed" do
    User.create!(email: "taken@example.com", password: "password123", password_confirmation: "password123")

    visit "/signup"

    fill_in "Email", with: "taken@example.com"
    fill_in "Password", with: "password456"
    fill_in "Password confirmation", with: "password456"

    click_button "Sign up"

    assert_text "prohibited this user from being saved"
  end
end
