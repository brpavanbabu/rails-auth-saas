# frozen_string_literal: true

# LTI 1.3 Platform Model
# Represents an LMS (Canvas, Moodle, Blackboard, etc.)
class LtiPlatform < ApplicationRecord
  belongs_to :account
  has_many :lti_registrations, dependent: :destroy
  has_many :lti_resource_links, dependent: :destroy
  has_many :lti_launches, dependent: :destroy

  validates :issuer, :client_id, :auth_endpoint, :token_endpoint, :jwks_endpoint, presence: true
  validates :issuer, uniqueness: { scope: :client_id }

  encrypts :public_key if Rails.application.credentials.secret_key_base.present?

  scope :active, -> { where(active: true) }

  # Fetch JWKS (JSON Web Key Set) from platform
  def fetch_jwks
    response = HTTP.get(jwks_endpoint)
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "Failed to fetch JWKS: #{e.message}"
    nil
  end

  # Verify JWT token from platform
  def verify_jwt(token)
    jwks = fetch_jwks
    return false unless jwks

    JWT.decode(token, nil, true, {
      algorithms: ['RS256'],
      jwks: jwks,
      iss: issuer,
      aud: client_id
    })
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT verification failed: #{e.message}"
    false
  end
end
