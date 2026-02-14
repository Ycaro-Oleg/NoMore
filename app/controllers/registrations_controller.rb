class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  layout "auth"

  def new
    redirect_to root_path if current_user
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created. No more excuses — time to commit."
    else
      flash.now[:alert] = @user.errors.full_messages.join(". ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
