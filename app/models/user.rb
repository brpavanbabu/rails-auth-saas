# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :oauth_accounts, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships

  generates_token_for :magic_link, expires_in: 15.minutes
  generates_token_for :email_verification, expires_in: 24.hours

  encrypts :otp_secret
  encrypts :otp_backup_codes

  before_save :normalize_email
  after_create :send_verification_email

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?

  def enable_two_factor!
    secret = ROTP::Base32.random
    codes = generate_backup_codes
    update!(
      otp_secret: secret,
      otp_required_for_login: true,
      otp_backup_codes: codes.to_json
    )
    { secret: secret, backup_codes: codes, provisioning_uri: provisioning_uri(email) }
  end

  def disable_two_factor!
    update!(
      otp_secret: nil,
      otp_required_for_login: false,
      otp_backup_codes: nil
    )
  end

  def verify_otp(code)
    return false if otp_secret.blank? || code.blank?
    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code.to_s.strip, drift_behind: 30, drift_ahead: 30).present?
  end

  def consume_backup_code!(code)
    return false if otp_backup_codes.blank? || code.blank?
    codes = JSON.parse(otp_backup_codes)
    normalized = code.to_s.strip.upcase
    if codes.include?(normalized)
      codes.delete(normalized)
      update!(otp_backup_codes: codes.to_json)
      true
    else
      false
    end
  end

  def provisioning_uri(account_name)
    return nil unless otp_secret
    ROTP::TOTP.new(otp_secret, issuer: "RailsAuthSaaS").provisioning_uri(account_name)
  end

  def remember_me
    token = SecureRandom.urlsafe_base64(32)
    update!(remember_token: Digest::SHA256.hexdigest(token))
    token
  end

  def forget_me
    update!(remember_token: nil)
  end

  def self.find_by_remember_token(raw_token)
    return nil if raw_token.blank?
    hashed = Digest::SHA256.hexdigest(raw_token)
    find_by(remember_token: hashed)
  end

  def send_magic_link
    token = generate_token_for(:magic_link)
    UserMailer.magic_link(self, token).deliver_later
    token
  end

  def send_verification_email
    token = generate_token_for(:email_verification)
    UserMailer.verify_email(self, token).deliver_later
  end

  def verify_email!(token)
    if User.find_by_token_for(:email_verification, token) == self
      update!(email_verified_at: Time.current)
      true
    else
      false
    end
  end

  def email_verified?
    email_verified_at.present?
  end

  def self.from_omniauth(auth)
    oauth = OauthAccount.find_by(provider: auth.provider, uid: auth.uid)
    return oauth.user if oauth

    email = auth.info&.email&.strip&.downcase
    raise ArgumentError, "Email is required from #{auth.provider}" if email.blank?

    user = find_or_initialize_by(email: email)
    if user.new_record?
      password = SecureRandom.hex(32)
      user.password = password
      user.password_confirmation = password
      user.save!
    end

    user.oauth_accounts.create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info&.email,
      name: auth.info&.name,
      access_token: auth.credentials&.token
    )

    user
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def generate_backup_codes
    10.times.map { SecureRandom.alphanumeric(10).upcase }
  end
end
