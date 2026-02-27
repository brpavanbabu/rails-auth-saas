# frozen_string_literal: true

require "test_helper"

class SamlTest < ActionDispatch::IntegrationTest
  def setup
    @account = Account.create!(name: "Acme Corp")
    @saml_provider = SamlProvider.create!(
      account: @account,
      name: "Okta",
      entity_id: "https://acme.okta.com",
      sso_target_url: "https://acme.okta.com/sso",
      idp_cert: "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
      active: true
    )
  end

  test "GET /auth/saml/:id initiates SSO redirect" do
    get saml_initiate_path(account_id: @account.id)
    assert_response :redirect
    assert_match(/acme\.okta\.com/, redirect_to_url)
  end

  test "GET /auth/saml/:id/metadata returns XML" do
    get saml_metadata_path(account_id: @account.id)
    assert_response :success
    assert_equal "application/samlmetadata+xml", response.media_type
    assert_match(/EntityDescriptor/, response.body)
  end

  test "POST /auth/saml/:id/callback with invalid response redirects to login" do
    post saml_callback_path(account_id: @account.id), params: { SAMLResponse: "invalid" }
    assert_redirected_to login_path
    assert_match(/failed/, flash[:alert])
  end

  def redirect_to_url
    response.headers["Location"]
  end
end
