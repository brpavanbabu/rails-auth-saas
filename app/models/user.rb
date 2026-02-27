class User < ApplicationRecord
  has_secure_password
  has_many :oauth_accounts, dependent: :destroy

  generates_token_for :magic_link, expires_in: 15.minutes
  generates_token_for :email_verification, expires_in: 24.hours

  # Encrypt sensitive 2FA data
  encrypts :otp_secret
  encrypts :otp_backup_codes

  before_save :normalize_email
  after_create :send_verification_email

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, if: -> { password.present? }

  # Two-Factor Authentication
  def enable_two_factor!
    self.otp_secret = ROTP::Base32.random
    self.otp_backup_codes = generate_backup_codes.to_json
    save!
  end

  def disable_two_factor!
    self.otp_secret = nil
    self.otp_required_for_login = false
    self.otp_backup_codes = nil
    save!
  end

  def verify_otp(code)
    return false unless otp_secret
    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code, drift_behind: 30, drift_ahead: 30) || verify_backup_code(code)
  end

  def provisioning_uri(email)
    ROTP::TOTP.new(otp_secret, issuer: "RailsAuth").provisioning_uri(email)
  end

  def remember_me
    self.remember_token = SecureRandom.urlsafe_base64
    save!
  end

  def forget_me
    update!(remember_token: nil)
  end

  def self.find_by_remember_token(token)
    return nil if token.blank?
    # Use constant-time comparison to prevent timing attacks
    all.find { |u| u.remember_token.present? && ActiveSupport::SecurityUtils.secure_compare(u.remember_token, token) }
  end

  def send_magic_link
    token = generate_token_for(:magic_link)
    UserMailer.magic_link(self, token).deliver_later
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

    if oauth
      oauth.user
    else
      email = auth.info&.email&.strip&.downcase
      raise ArgumentError, "Email is required from #{auth.provider}" if email.blank?

      user = User.find_by(email: email)
      unless user
        password = SecureRandom.hex(32)
        user = User.create!(
          email: email,
          password: password,
          password_confirmation: password
        )
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
  end

  # Public method for consuming backup codes (called by controller)
  def consume_backup_code!(code)
    return false unless otp_backup_codes
    codes = JSON.parse(otp_backup_codes)
    if codes.include?(code)
      codes.delete(code)
      update!(otp_backup_codes: codes.to_json)
      true
    else
      false
    end
  end

  private

  def normalize_email
    self.email = email.strip.downcase
  end

  def generate_backup_codes
    10.times.map { SecureRandom.alphanumeric(10).upcase }
  end

  def verify_backup_code(code)
    return false unless otp_backup_codes
    codes = JSON.parse(otp_backup_codes)
    if codes.include?(code)
      codes.delete(code)
      update!(otp_backup_codes: codes.to_json)
      true
    else
      false
    end
  end
end
