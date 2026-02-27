# frozen_string_literal: true

require "test_helper"

class SamlProviderTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Acme Corp")
  end

  test "validates presence of required fields" do
    provider = SamlProvider.new(account: @account)
    assert_not provider.valid?
    assert_includes provider.errors[:name], "can't be blank"
    assert_includes provider.errors[:entity_id], "can't be blank"
    assert_includes provider.errors[:sso_target_url], "can't be blank"
  end

  test "valid with required fields" do
    provider = SamlProvider.new(
      account: @account,
      name: "Okta",
      entity_id: "https://acme.okta.com",
      sso_target_url: "https://acme.okta.com/sso"
    )
    assert provider.valid?
  end

  test "generates SAML settings correctly" do
    provider = SamlProvider.create!(
      account: @account,
      name: "Okta",
      entity_id: "https://acme.okta.com",
      sso_target_url: "https://acme.okta.com/sso",
      idp_cert: "-----BEGIN CERTIFICATE-----\ntest\n-----END CERTIFICATE-----",
      name_identifier_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    )

    request = OpenStruct.new(host: "example.com", base_url: "https://example.com")
    settings = provider.saml_settings(request: request)

    assert_equal "https://example.com/auth/saml/#{@account.id}/metadata", settings.sp_entity_id
    assert_equal "https://example.com/auth/saml/#{@account.id}/callback", settings.assertion_consumer_service_url
    assert_equal "https://acme.okta.com", settings.idp_entity_id
    assert_equal "https://acme.okta.com/sso", settings.idp_sso_service_url
    assert_includes settings.idp_cert, "CERTIFICATE"
    assert_equal "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress", settings.name_identifier_format
  end

  test "active scope returns only active providers" do
    active = SamlProvider.create!(
      account: @account,
      name: "Okta",
      entity_id: "https://okta.com",
      sso_target_url: "https://okta.com/sso",
      active: true
    )
    inactive = SamlProvider.create!(
      account: @account,
      name: "Azure",
      entity_id: "https://azure.com",
      sso_target_url: "https://azure.com/sso",
      active: false
    )

    assert_includes SamlProvider.active, active
    assert_not_includes SamlProvider.active, inactive
  end
end
