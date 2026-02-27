# frozen_string_literal: true

class OauthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_action :require_login, only: [:destroy]

  def callback
    auth = request.env["omniauth.auth"]
    return redirect_to login_path, alert: "Authentication failed." unless auth

    if logged_in?
      link_oauth_to_current_user(auth)
      redirect_to dashboard_path, notice: "Account linked successfully."
    else
      user = User.from_omniauth(auth)
      login_user(user)
      redirect_to dashboard_path, notice: "Successfully authenticated with #{params[:provider]&.titleize}"
    end
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  def destroy
    account = current_user.oauth_accounts.find_by(provider: params[:provider])
    return redirect_to dashboard_path, alert: "Provider not linked." unless account

    unless can_unlink?(account)
      redirect_to dashboard_path, alert: "Cannot unlink: you need a password or another sign-in method."
      return
    end

    account.destroy!
    redirect_to dashboard_path, notice: "#{params[:provider]&.titleize} account disconnected"
  end

  private

  def link_oauth_to_current_user(auth)
    current_user.oauth_accounts.create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info&.email,
      name: auth.info&.name,
      access_token: auth.credentials&.token
    )
  end

  def can_unlink?(account)
    # Allow if user has password OR another OAuth provider
    current_user.oauth_accounts.count > 1 || current_user.password_digest.present?
  end
end
