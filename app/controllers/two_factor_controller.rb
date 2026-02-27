# frozen_string_literal: true

class TwoFactorController < ApplicationController
  before_action :require_login, except: [ :verify ]

  def setup
    unless current_user.otp_secret.present?
      current_user.update!(otp_secret: ROTP::Base32.random)
    end
    @qr_code = generate_qr_code(current_user.email, current_user.otp_secret)
  end

  def enable
    if current_user.verify_otp(params[:otp_code])
      result = current_user.enable_two_factor!
      flash[:notice] = "Two-factor authentication enabled. Save your backup codes: #{result[:backup_codes].join(', ')}"
      redirect_to dashboard_path
    else
      redirect_to two_factor_setup_path, alert: "Invalid verification code. Please try again."
    end
  end

  def verify
    return unless request.post?

    user = User.find_by(id: session[:pending_2fa_user_id])
    if user && (user.verify_otp(params[:otp_code]) || user.consume_backup_code!(params[:otp_code]))
      session.delete(:pending_2fa_user_id)
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back!"
    else
      flash.now[:alert] = "Invalid verification code."
      render :verify, status: :unprocessable_entity
    end
  end

  def disable
    current_user.disable_two_factor!
    redirect_to dashboard_path, notice: "Two-factor authentication disabled."
  end

  private

  def generate_qr_code(account, secret)
    totp = ROTP::TOTP.new(secret, issuer: "RailsAuthSaaS")
    RQRCode::QRCode.new(totp.provisioning_uri(account))
  end
end
