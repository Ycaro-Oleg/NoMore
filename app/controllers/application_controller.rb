class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!

  private

  def current_user
    @current_user ||= if session[:user_id]
      User.find_by(id: session[:user_id])
    end
  end
  helper_method :current_user

  def authenticate_user!
    unless current_user
      redirect_to login_path, alert: "You need to sign in first. No excuses."
    end
  end

  def set_current_user
    Current.user = current_user
  end
end
