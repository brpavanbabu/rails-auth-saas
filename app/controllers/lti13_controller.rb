# frozen_string_literal: true

# LTI 1.3 Controller
# Handles LMS launches and authentication
class Lti13Controller < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:launch, :oidc_login]
  skip_before_action :require_login

  # OIDC Login Initiation (Step 1)
  def oidc_login
    # LTI 1.3 OIDC authentication flow
    platform = find_platform_by_params
    
    unless platform
      render json: { error: 'Platform not found' }, status: :not_found
      return
    end

    # Generate state and nonce
    state = SecureRandom.hex(32)
    nonce = SecureRandom.hex(32)
    
    session[:lti_state] = state
    session[:lti_nonce] = nonce

    # Build authorization redirect URL
    auth_params = {
      response_type: 'id_token',
      client_id: platform.client_id,
      redirect_uri: lti_launch_url,
      login_hint: params[:login_hint],
      lti_message_hint: params[:lti_message_hint],
      state: state,
      nonce: nonce,
      prompt: 'none',
      response_mode: 'form_post',
      scope: 'openid'
    }

    redirect_to "#{platform.auth_endpoint}?#{auth_params.to_query}", allow_other_host: true
  end

  # Launch Endpoint (Step 2)
  def launch
    # Verify state
    unless params[:state] == session[:lti_state]
      render json: { error: 'Invalid state' }, status: :forbidden
      return
    end

    # Decode and verify JWT
    id_token = params[:id_token]
    platform = find_platform_by_jwt(id_token)
    
    unless platform
      render json: { error: 'Platform not found' }, status: :not_found
      return
    end

    decoded_token = platform.verify_jwt(id_token)
    
    unless decoded_token
      render json: { error: 'Invalid JWT' }, status: :forbidden
      return
    end

    claims = decoded_token.first

    # Verify nonce
    unless claims['nonce'] == session[:lti_nonce]
      render json: { error: 'Invalid nonce' }, status: :forbidden
      return
    end

    # Extract LTI claims
    lti_claims = claims['https://purl.imsglobal.org/spec/lti/claim/'] || {}
    
    # Find or create user from LTI
    user = find_or_create_lti_user(claims)
    
    # Find or create resource link
    resource_link = find_or_create_resource_link(platform, lti_claims)

    # Log the launch
    LtiLaunch.log_launch(
      user: user,
      platform: platform,
      resource_link: resource_link,
      lti_user_id: claims['sub'],
      context_id: lti_claims['context']&.dig('id'),
      role: extract_primary_role(lti_claims['roles']),
      params: claims
    )

    # Log in user
    reset_session
    session[:user_id] = user.id
    session[:lti_launch] = true
    session[:lti_platform_id] = platform.id

    # Redirect to resource or dashboard
    redirect_to lti_resource_path(resource_link)
  end

  # JWKS Endpoint (Public keys for platform)
  def jwks
    registration = LtiRegistration.find_by(registration_id: params[:registration_id])
    
    unless registration
      render json: { error: 'Registration not found' }, status: :not_found
      return
    end

    jwks = JSON.parse(registration.public_jwk)
    render json: jwks
  end

  private

  def find_platform_by_params
    LtiPlatform.find_by(
      issuer: params[:iss],
      client_id: params[:client_id]
    )
  end

  def find_platform_by_jwt(token)
    # Decode without verification to get issuer
    decoded = JWT.decode(token, nil, false)
    claims = decoded.first
    
    LtiPlatform.find_by(
      issuer: claims['iss'],
      client_id: claims['aud']
    )
  end

  def find_or_create_lti_user(claims)
    lti_user_id = claims['sub']
    email = claims['email'] || "lti_#{lti_user_id}@example.com"
    name = claims['name'] || claims['given_name'] || 'LTI User'

    user = User.find_by(lti_user_id: lti_user_id) || User.find_by(email: email)
    
    unless user
      password = SecureRandom.hex(32)
      user = User.create!(
        email: email,
        password: password,
        password_confirmation: password,
        lti_enabled: true,
        lti_user_id: lti_user_id
      )
    end

    user.update!(lti_user_id: lti_user_id) unless user.lti_user_id
    user
  end

  def find_or_create_resource_link(platform, lti_claims)
    resource_link_claim = lti_claims['resource_link']
    return nil unless resource_link_claim

    context = lti_claims['context'] || {}
    
    LtiResourceLink.find_or_create_by!(
      lti_platform: platform,
      resource_link_id: resource_link_claim['id']
    ) do |link|
      link.context_id = context['id']
      link.context_title = context['title']
      link.resource_title = resource_link_claim['title']
      link.custom_parameters = lti_claims['custom'].to_json if lti_claims['custom']
    end
  end

  def extract_primary_role(roles)
    return 'Learner' unless roles

    # Priority order: Instructor > TeachingAssistant > Learner
    return 'Instructor' if roles.any? { |r| r.include?('Instructor') }
    return 'TeachingAssistant' if roles.any? { |r| r.include?('TeachingAssistant') }
    'Learner'
  end

  def lti_resource_path(resource_link)
    # Customize this to your app's resource routing
    resource_link ? "/lti/resources/#{resource_link.id}" : dashboard_path
  end
end
