class UsersController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome! You have signed up successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
