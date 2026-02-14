class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  layout "auth"

  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back. Your commitments didn't go anywhere."
    else
      flash.now[:alert] = "Wrong credentials. Running from your own password now?"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Logged out. The clock doesn't stop because you left."
  end
end
