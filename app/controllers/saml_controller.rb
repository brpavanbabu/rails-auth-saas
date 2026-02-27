# frozen_string_literal: true

class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]

  def initiate
    saml_provider = find_active_saml_provider
    request_obj = OneLogin::RubySaml::Authrequest.new
    redirect_to request_obj.create(saml_provider.saml_settings(request: request)), allow_other_host: true
  end

  def callback
    saml_provider = find_active_saml_provider
    settings = saml_provider.saml_settings(request: request)
    response_obj = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: settings)

    if response_obj.is_valid?
      user = find_or_create_user_from_saml(response_obj, saml_provider)
      add_user_to_account_if_needed(user, saml_provider)
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in with SSO successfully!"
    else
      Rails.logger.error "SAML validation failed: #{response_obj.errors.join(', ')}"
      redirect_to login_path, alert: "SSO sign-in failed. Please try again or use your password."
    end
  end

  def metadata
    saml_provider = find_active_saml_provider
    meta = OneLogin::RubySaml::Metadata.new
    xml = meta.generate(saml_provider.saml_settings(request: request))
    render xml: xml, content_type: "application/samlmetadata+xml"
  end

  private

  def find_active_saml_provider
    SamlProvider.active.joins(:account).find_by!(accounts: { id: params[:account_id] })
  end

  def find_or_create_user_from_saml(response_obj, saml_provider)
    nameid = response_obj.nameid
    attrs = response_obj.attributes

    email = extract_email(attrs, nameid)
    user = User.find_by(saml_uid: nameid) || User.find_by(email: email)

    if user
      user.update!(saml_uid: nameid) if user.saml_uid.blank?
      user
    else
      User.create!(
        email: email,
        password: SecureRandom.hex(32),
        saml_uid: nameid
      )
    end
  end

  def extract_email(attrs, fallback)
    return fallback if attrs.blank?
    %w[email mail http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress].each do |key|
      val = attrs[key.to_sym] || attrs[key]
      next if val.blank?
      return val.is_a?(Array) ? val.first : val
    end
    fallback
  end

  def add_user_to_account_if_needed(user, saml_provider)
    return if user.accounts.include?(saml_provider.account)
    saml_provider.account.account_memberships.create!(user: user, role: "member")
  end
end
