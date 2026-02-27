# frozen_string_literal: true

require "application_system_test_case"

class TwoFactorTest < ApplicationSystemTestCase
  test "user can enable 2FA" do
    user = User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")

    visit "/login"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password123"
    click_button "Log in"

    visit "/two_factor/setup"
    assert_text "Two-Factor Authentication"
    assert_text "QR code"
  end
end
