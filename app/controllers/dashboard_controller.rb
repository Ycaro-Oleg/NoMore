class DashboardController < ApplicationController
  def show
    @commitments = current_user.commitments.order(created_at: :desc)
    @active_commitments = @commitments.active
    @analytics = ::UserAnalytics.new(current_user)
    @messages = ::ConfrontationalMessages.new(@analytics)
  end
end
