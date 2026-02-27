# frozen_string_literal: true

class LtiPlatform < ApplicationRecord
  belongs_to :account
  has_many :lti_registrations, dependent: :destroy
  has_many :lti_resource_links, dependent: :destroy
  has_many :lti_launches, dependent: :destroy

  validates :issuer, :client_id, :auth_endpoint, :token_endpoint, :jwks_endpoint, presence: true
  validates :issuer, uniqueness: { scope: :client_id }

  encrypts :public_key

  scope :active, -> { where(active: true) }

  def fetch_jwks
    require "net/http"
    uri = URI(jwks_endpoint)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    Rails.logger.error "Failed to fetch JWKS from #{jwks_endpoint}: #{e.message}"
    nil
  end

  def verify_jwt(token)
    jwks = fetch_jwks
    return false unless jwks

    JWT.decode(token, nil, true, {
      algorithms: [ "RS256" ],
      jwks: jwks,
      iss: issuer,
      aud: client_id
    })
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT verification failed: #{e.message}"
    false
  end
end
