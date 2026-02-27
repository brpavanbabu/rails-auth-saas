# frozen_string_literal: true

class OauthAccount < ApplicationRecord
  belongs_to :user

  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }

  # Encrypt access tokens at rest using application secret
  encrypts :access_token
end
