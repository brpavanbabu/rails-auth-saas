class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, alert: "Too many attempts" }

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.strip&.downcase)

    if user&.authenticate(params[:password])
      if user.otp_required_for_login?
        # User has 2FA enabled - require OTP verification
        session[:pending_2fa_user_id] = user.id
        redirect_to two_factor_verify_path
      else
        # Normal login flow
        reset_session
        session[:user_id] = user.id
        if params[:remember_me] == "1"
          user.remember_me
          cookies.permanent.encrypted[:remember_token] = user.remember_token
        end
        redirect_to root_path, notice: "Welcome back!"
      end
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user&.forget_me
    cookies.delete(:remember_token)
    reset_session
    redirect_to login_path, notice: "You have been logged out."
  end
end
