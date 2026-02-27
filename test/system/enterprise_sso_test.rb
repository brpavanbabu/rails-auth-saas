# frozen_string_literal: true

require "application_system_test_case"

class EnterpriseSsoTest < ApplicationSystemTestCase
  def setup
    @account = Account.create!(name: "Acme Corp")
    @user = User.create!(
      email: "admin@acme.com",
      password: "password123",
      password_confirmation: "password123"
    )
    AccountMembership.create!(account: @account, user: @user, role: "admin")
  end

  test "admin can configure SAML provider" do
    sign_in @user
    visit admin_account_saml_providers_path(@account)

    click_on "Add SAML Provider"
    fill_in "Name", with: "Okta"
    fill_in "Entity id", with: "https://acme.okta.com"
    fill_in "Sso target url", with: "https://acme.okta.com/sso"
    fill_in "Idp cert", with: "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----"
    click_on "Create Saml provider"

    assert_text "SAML provider was successfully created"
    assert_text "Okta"
    assert_text "https://acme.okta.com"
  end

  test "guest cannot access admin SSO config" do
    visit admin_account_saml_providers_path(@account)
    assert_current_path login_path
  end

  private

  def sign_in(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Log in"
  end
end
