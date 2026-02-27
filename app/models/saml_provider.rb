# frozen_string_literal: true

class SamlProvider < ApplicationRecord
  belongs_to :account

  encrypts :idp_cert

  validates :name, presence: true
  validates :entity_id, presence: true
  validates :sso_target_url, presence: true
  validates :entity_id, uniqueness: { scope: :account_id }

  scope :active, -> { where(active: true) }

  DEFAULT_NAME_ID_FORMAT = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  def saml_settings(request: nil)
    settings = OneLogin::RubySaml::Settings.new

    settings.sp_entity_id = sp_entity_id(request)
    settings.assertion_consumer_service_url = acs_url(request)
    settings.idp_entity_id = entity_id
    settings.idp_sso_service_url = sso_target_url
    settings.idp_cert = idp_cert if idp_cert.present?
    settings.name_identifier_format = name_identifier_format.presence || DEFAULT_NAME_ID_FORMAT

    settings
  end

  private

  def sp_entity_id(request)
    return "urn:rubyonrails:saml" if request.blank?
    "https://#{request.host}/auth/saml/#{account_id}/metadata"
  end

  def acs_url(request)
    return "urn:rubyonrails:saml:acs" if request.blank?
    "#{request.base_url}/auth/saml/#{account_id}/callback"
  end
end
